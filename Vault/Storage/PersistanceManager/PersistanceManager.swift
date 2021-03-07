//
//  PersistanceManager.swift
//  Vault
//
//  Created by Abhishek Agarwal on 08/03/2021.
//  Copyright © 2021 Test. All rights reserved.
//

import Foundation
import RxSwift

protocol PersistanceManager {
  func createAlbum(havingName name: String) -> Single<Vault>
  func listAlbums() -> Single<Vault>
  func deleteAlbum(havingName name: String) -> Single<Vault>

  func saveFile(havingName name: String, in album: Album, ofType type: MediaType, withData data: Data) -> Single<Vault>
  func listFiles(in album: Album) -> Single<[File]>

  func getData(at path: String) -> Single<Data>

  func getVault() -> Single<Vault>
}

class PersistanceManagerImpl: PersistanceManager {

  private let client: StorageClient
  private let basePath = "vault"
  private let vaultFileName = "vault.txt"
  private var vault: Vault!

  init(client: StorageClient = FileManagerClient.instance) {
    self.client = client
  }

  func createAlbum(havingName name: String) -> Single<Vault> {
    return client
      .createDirectory(having: effectivePath(for: name))
      .andThen(getVault())
      .flatMapCompletable { [unowned self] in
        let album = Album(name: name, path: effectivePath(for: name))
        $0.albums.append(album)
        return self.saveVault()
      }
      .andThen(Single.deferred { [unowned self] in .just(self.vault) })
  }

  func listAlbums() -> Single<Vault> {
    return Single.deferred { [unowned self] in
      guard self.vault == nil else { return .just(self.vault) }
      return self.getVault()
    }
  }

  func deleteAlbum(havingName name: String) -> Single<Vault> {
    return
      self.getVault()
      .flatMapCompletable { [unowned self] _ in self.client.delete(at: effectivePath(for: name)) }
      .do(onCompleted: { [unowned self] in self.vault.albums = self.vault.albums.filter { $0.name != name } })
      .andThen(saveVault())
      .andThen(Single.deferred { [unowned self] in .just(self.vault) })
  }

  func saveFile(havingName name: String, in album: Album, ofType type: MediaType, withData data: Data) -> Single<Vault> {
    let path = effectivePath(for: "\(album.name)/\(name)")
    return client
      .persist(data: data, at: path)
      .do(onCompleted: { ImageRetriever.instance.save(data: data, at: path) })
      .andThen(Single.deferred { .just(File(name: name, type: type, path: path)) })
      .flatMap { [unowned self] file in
        self.vault.albums.first { $0 == album }.map { $0.files.append(file) }
        return saveVault()
          .andThen(Single.deferred { [unowned self] in .just(self.vault) })
      }
  }

  func listFiles(in album: Album) -> Single<[File]> {
    return Single.deferred { [unowned self] in
      guard self.vault == nil else {
        return .just(self.vault.albums.first { $0 == album }?.files ?? [])
      }
      return self.getVault()
        .map { $0.albums.first{ $0 == album }?.files ?? [] }
    }
  }

  func getData(at path: String) -> Single<Data> {
    return client.loadObject(at: path, ofType: Data.self)
  }

  func getVault() -> Single<Vault> {
    return self.client
      .loadObject(at: self.effectivePath(for: vaultFileName), ofType: Vault.self)
      .catchError { error in
        if case StorageClientError.doesNotExists = error {
          return .just(Vault())
        }
        return .error(error)
      }.do(onSuccess: { [unowned self] in
        self.vault = $0
        queue.async {
          ImageRetriever.instance.cache(from: vault.albums.flatMap { $0.files }.compactMap { $0.path })
        }
      })
  }

  // MARK :- Private helpers
  private let disposeBag = DisposeBag()
  private let queue = DispatchQueue(label: "PersistanceManager",
                                    qos: .background,
                                    attributes: .concurrent,
                                    target: nil)
  private lazy var scheduler = ConcurrentDispatchQueueScheduler(queue: queue)

  private func effectivePath(for name: String = "") -> String {
    return "\(basePath)/\(name)"
  }

  private func saveVault() -> Completable {
    return self.client.persist(object: self.vault, at: effectivePath(for: vaultFileName))
  }

}

class ImageRetriever {
  private init() { }

  static let instance = ImageRetriever()

  var images = [String: UIImage]()

  func cache(from paths: [String]) {
    paths.forEach { getImage(at: $0) }
  }

  func save(data: Data, at path: String) {
    guard let image = UIImage(data: data) else { return }
    images[path] = image
  }

  @discardableResult
  func getImage(at path: String) -> UIImage? {
    guard let image = images[path] else {
      let image = retrieveImageFromFilePath(path)
      images[path] = image
      return nil
    }
    return image
  }

  func retrieveImageFromFilePath(_ path: String) -> UIImage? {
    let requiredURL = FileManager.default
      .urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(path)
    guard let data = try? Data(contentsOf: requiredURL),
          let image = UIImage(data: data) else { return nil }
    return image
  }
}
