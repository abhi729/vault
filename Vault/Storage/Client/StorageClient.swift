//
//  StorageClient.swift
//  Vault
//
//  Created by Abhishek Agarwal on 08/03/2021.
//  Copyright © 2021 Test. All rights reserved.
//

import Foundation
import RxSwift

enum StorageClientError: Error {
  case failedToPersist
  case failedToLoad
  case failedToDelete
  case alreadyExists
  case doesNotExists
}

protocol StorageClient {
  func createDirectory(having path: String) -> Completable
  func persist<Object>(object: Object, at path: String) -> Completable where Object: Encodable
  func loadObject<Object>(at path: String, ofType type: Object.Type) -> Single<Object> where Object: Decodable
  func delete(at path: String) -> Completable
  func persist(data: Data, at path: String) -> Completable
}

class FileManagerClient: StorageClient {

  private init() { print("Haha", defaultPath) }
  static let instance = FileManagerClient()

  func createDirectory(having path: String) -> Completable {
    let fileURL = requiredURL(for: path)
    return confirmDoesNotExist(at: fileURL)
      .andThen(createDirectory(at: fileURL))
  }

  func persist<Object>(object: Object, at path: String) -> Completable where Object: Encodable {
    let fileURL = requiredURL(for: path)
    return getData(from: object)
      .flatMapCompletable { [unowned self] in self.save(data: $0, at: fileURL) }
  }

  func loadObject<Object>(at path: String, ofType type: Object.Type) -> Single<Object> where Object: Decodable {
    let fileURL = requiredURL(for: path)
    return confirmDoesExist(at: fileURL)
      .andThen(getData(from: fileURL))
      .flatMap { [unowned self] in self.getObject(from: $0, ofType: type) }
  }

  func delete(at path: String) -> Completable {
    let fileURL = requiredURL(for: path)
    return confirmDoesExist(at: fileURL)
      .andThen(deleteData(at: fileURL))
  }

  func persist(data: Data, at path: String) -> Completable {
    let fileURL = requiredURL(for: path)
    return confirmDoesNotExist(at: fileURL)
      .andThen(save(data: data, at: fileURL))
  }

  // MARK:- Private helpers
  private let manager = FileManager.default
  private let defaultPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

  private func getData<Object>(from object: Object) -> Single<Data> where Object: Encodable {
    return Single.deferred {
      let encoder = JSONEncoder()
      do {
        let data = try encoder.encode(object)
        return .just(data)
      } catch let error {
        return .error(error)
      }
    }
  }

  private func getObject<Object>(from data: Data, ofType type: Object.Type) -> Single<Object> where Object: Decodable {
    return Single.deferred {
      let decoder = JSONDecoder()
      do {
        let object = try decoder.decode(type, from: data)
        return .just(object)
      } catch let error {
        return .error(error)
      }
    }
  }

  private func requiredURL(for path: String) -> URL {
    return defaultPath.appendingPathComponent(path)
  }

  private func confirmDoesNotExist(at fileURL: URL) -> Completable {
    return Completable.deferred { [unowned self] in
      if !self.manager.fileExists(atPath: fileURL.path) {
        return .empty()
      } else {
        return .error(StorageClientError.alreadyExists)
      }
    }
  }

  private func confirmDoesExist(at fileURL: URL) -> Completable {
    return Completable.deferred { [unowned self] in
      if self.manager.fileExists(atPath: fileURL.path) {
        return .empty()
      } else {
        return .error(StorageClientError.doesNotExists)
      }
    }
  }

  private func createDirectory(at url: URL) -> Completable {
    return Completable.deferred { [unowned self] in
      do {
        try manager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        return .empty()
      } catch let error {
        return .error(error)
      }
    }
  }

  private func save(data: Data, at url: URL) -> Completable {
    return Completable.deferred {
      do {
        try data.write(to: url)
        return .empty()
      } catch let error {
        return .error(error)
      }
    }
  }

  private func getData(from url: URL) -> Single<Data> {
    return Single.deferred {
      do {
        let data = try Data(contentsOf: url)
        return .just(data)
      } catch let error {
        return .error(error)
      }
    }
  }

  private func deleteData(at url: URL) -> Completable {
    return Completable.deferred { [unowned self] in
      do {
        try manager.removeItem(at: url)
        return .empty()
      } catch let error {
        return .error(error)
      }
    }
  }
}
