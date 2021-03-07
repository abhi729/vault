//
//  HomeViewModel.swift
//  Vault
//
//  Created by Abhishek Agarwal on 13/03/2021.
//  Copyright © 2021 Test. All rights reserved.
//

import Foundation
import RxSwift

fileprivate enum DisplayMode {
  case login
  case albums
  case files(inAlbum: Album)
  case file(details: File, inAlbum: Album)
}

protocol HomeViewModelInput: class {
  func viewLoaded()
  func viewAppeared()
  func loginSuccessful()
  func numberOfItems(inSection section: Int) -> Int
  func cellViewModel(for index: IndexPath) -> HomeCellModelInput
  func createAlbum(havingName name: String)
  func didSelectItem(at indexPath: IndexPath)
  func backToAlbumsTapped()
  func didAddImage(_ image: UIImage)
}

class HomeViewModel: HomeViewModelInput {

  init(output: HomeViewControllerOutput,
       manager: PersistanceManager = PersistanceManagerImpl()) {
    self.output = output
    self.manager = manager
  }

  // MARK :- HomeViewModelInput Implementation
  func viewLoaded() {
    setupVaultObserver()
  }

  func viewAppeared() {
    showLoginScreenIfRequired()
    getVault()
  }

  func loginSuccessful() {
    displayMode = .albums
  }

  func numberOfItems(inSection section: Int) -> Int {
    switch displayMode {
    case .albums:
      return vault.albums.count
    case .files(inAlbum: let album):
      return vault.albums.first { $0 == album }?.files.count ?? 0
    default:
      return 0
    }
  }

  func cellViewModel(for index: IndexPath) -> HomeCellModelInput {
    switch displayMode {
    case .albums:
      return HomeCellViewModel(file: vault.albums[index.item])
    case .files(inAlbum: let album):
      let file = vault.albums.first { $0 == album }?.files[index.item]
      return HomeCellViewModel(file: file!)
    default:
      fatalError("Unimplemented")
    }
  }

  func createAlbum(havingName name: String) {
    manager.createAlbum(havingName: name)
      .observeOn(MainScheduler.instance)
      .subscribe(onSuccess: { [unowned self] in self.vaultSubject.onNext($0) })
      .disposed(by: disposeBag)
  }

  func didSelectItem(at indexPath: IndexPath) {
    switch displayMode {
    case .albums:
      displayMode = .files(inAlbum: vault.albums[indexPath.item])
    case .files(inAlbum: let album):
      displayMode = .file(details: album.files[indexPath.item], inAlbum: album)
    default:
      break
    }
  }

  func backToAlbumsTapped() {
    displayMode = .albums
  }

  func didAddImage(_ image: UIImage) {
    guard case .files(inAlbum: let album) = displayMode,
          let data = image.jpegData(compressionQuality: 0.25) else { return }
    let name = "\(Int(Date().timeIntervalSince1970)).jpeg"
    manager.saveFile(havingName: name, in: album, ofType: .image, withData: data)
      .observeOn(MainScheduler.instance)
      .subscribe(onSuccess: { [unowned self] in
                  self.vaultSubject.onNext($0)
      })
      .disposed(by: disposeBag)
  }

  // MARK :- Private helpers
  private var displayMode = DisplayMode.login {
    didSet {
      switch displayMode {
      case .albums:
        getVault()
        output.showViewForAlbums()
        output.showCreateAlbumButton()
        output.hideBackToAlbumsButton()
        output.reloadList()
      case .files(inAlbum: let album):
        output.showCameraAndGalleryButtons()
        output.showViewForFiles(in: album.name)
        output.showBackToAlbumsButton()
        output.reloadList()
      case .file(details: let file, inAlbum: let album):
        output.routeToFileDetailScreen(withModel: FileDetailViewModel(file: file))
        displayMode = .files(inAlbum: album)
      default:
        break
      }
    }
  }

  private let disposeBag = DisposeBag()
  private unowned let output: HomeViewControllerOutput
  private let manager: PersistanceManager
  private let vaultSubject = PublishSubject<Vault>.init()

  private var vault: Vault! {
    didSet {
      DispatchQueue.main.async { self.handleVaultChanges() }
    }
  }

  private func handleVaultChanges() {
    setupDefaultAlbumIfRequired()
    output.reloadList()
  }

  private func setupDefaultAlbumIfRequired() {
    guard vault.albums.isEmpty else { return }
    manager
      .createAlbum(havingName: "Main Album")
      .subscribe(onSuccess: { [weak self] in self?.vaultSubject.onNext($0) })
      .disposed(by: disposeBag)
  }

  private func setupVaultObserver() {
    vaultSubject
      .asObservable()
      .subscribe(onNext: { [weak self] vault in self?.vault = vault })
      .disposed(by: disposeBag)
  }

  private func getVault() {
    guard vault == nil else { return }
    if case .login = displayMode { return }
    manager.getVault()
      .subscribe(onSuccess: { [weak self] in self?.vaultSubject.onNext($0) })
      .disposed(by: disposeBag)
  }

  private func showLoginScreenIfRequired() {
    guard case .login = displayMode else { return }
    output.showLoginScreen()
  }

}
