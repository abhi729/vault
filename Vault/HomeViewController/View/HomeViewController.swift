//
//  HomeViewController.swift
//  Vault
//
//  Created by Abhishek Agarwal on 13/03/2021.
//  Copyright © 2021 Test. All rights reserved.
//

import UIKit

protocol HomeViewControllerInput: class {
  func loginSuccessful()
}

protocol HomeViewControllerOutput: class {
  func showLoginScreen()
  func reloadList()
  func showCreateAlbumButton()
  func showCameraAndGalleryButtons()
  func showViewForFiles(in album: String)
  func showBackToAlbumsButton()
  func hideBackToAlbumsButton()
  func showViewForAlbums()
  func routeToFileDetailScreen(withModel model: FileDetailInput)
}

class HomeViewController: UIViewController, HomeViewControllerOutput, HomeViewControllerInput {

  @IBOutlet weak var listView: UIView!
  @IBOutlet weak var listCollectionView: UICollectionView!
  @IBOutlet weak var listDescriptionLabel: UILabel!

  private var input: HomeViewModelInput!
  private var addAlbumButton: UIBarButtonItem?
  private var cameraButton: UIBarButtonItem?
  private var galleryButton: UIBarButtonItem?
  private var backToAlbumsButton: UIBarButtonItem?

  override func viewDidLoad() {
    super.viewDidLoad()

    input = HomeViewModel(output: self)
    input.viewLoaded()

    listCollectionView.collectionViewLayout = LeftAlignedCollectionViewLayout()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    input.viewAppeared()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Constants.homeToLoginSegue {
      (segue.destination as? LoginViewController).map { $0.input = self }
    } else if segue.identifier == Constants.homeToDetailSegue {
      guard let model = sender as? FileDetailInput else { return }
      (segue.destination as? FileDetailViewInput)?.setupViewModel(model)
    }
  }

  // MARK :- HomeViewControllerOutput Implementation
  func showLoginScreen() {
    performSegue(withIdentifier: Constants.homeToLoginSegue, sender: self)
  }

  func loginSuccessful() {
    input.loginSuccessful()
  }

  func reloadList() {
    listCollectionView.reloadData()
  }

  func showCreateAlbumButton() {
    if addAlbumButton == nil {
      addAlbumButton = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(addAlbum))
    }
    addAlbumButton.map { navigationItem.rightBarButtonItems = [$0] }
  }

  func showCameraAndGalleryButtons() {
    if cameraButton == nil {
      cameraButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(openCamera))
    }
    if galleryButton == nil {
      galleryButton = UIBarButtonItem(title: "Gallery", style: .plain, target: self, action: #selector(openGallery))
    }
    navigationItem.rightBarButtonItems = [cameraButton, galleryButton].compactMap { $0 }
  }

  func showViewForFiles(in album: String) {
    listDescriptionLabel.text = album
  }

  func showBackToAlbumsButton() {
    if backToAlbumsButton == nil {
      backToAlbumsButton = UIBarButtonItem(title: "< Albums",
                                           style: .plain,
                                           target: self,
                                           action: #selector(backToAlbums))
    }
    navigationItem.leftBarButtonItem = backToAlbumsButton
  }

  func hideBackToAlbumsButton() {
    navigationItem.leftBarButtonItem = nil
  }

  func showViewForAlbums() {
    listDescriptionLabel.text = "Albums"
  }

  func routeToFileDetailScreen(withModel model: FileDetailInput) {
    performSegue(withIdentifier: Constants.homeToDetailSegue, sender: model)
  }

  // MARK :- Private helpers
  @objc private func openCamera() {
    guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
      let alertVC = UIAlertController(title: "Oops!!", message: "Camera Unavailable", preferredStyle: .alert)
      let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in })
      alertVC.addAction(okAction)
      present(alertVC, animated: true, completion: nil)
      return
    }
    let cameraVC = UIImagePickerController()
    cameraVC.sourceType = .camera
    cameraVC.delegate = self
    present(cameraVC, animated: true, completion: nil)
  }

  @objc private func openGallery() {
    let galleryVC = UIImagePickerController()
    galleryVC.sourceType = .photoLibrary
    galleryVC.delegate = self
    present(galleryVC, animated: true, completion: nil)
  }

  @objc private func backToAlbums() {
    input.backToAlbumsTapped()
  }

  @objc private func addAlbum() {
    let alertVC = UIAlertController(title: "Add Album", message: "Enter album name", preferredStyle: .alert)
    alertVC.addTextField()

    let createAction = UIAlertAction(title: "Create", style: .default) { [unowned alertVC, unowned self] _ in
      let albumName = alertVC.textFields?[0].text ?? ""
      self.input.createAlbum(havingName: albumName)
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { _ in })

    alertVC.addAction(cancelAction)
    alertVC.addAction(createAction)

    present(alertVC, animated: true)
  }

}

extension HomeViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return input.numberOfItems(inSection: section)
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.identifier,
                                                  for: indexPath) as! HomeCollectionViewCell
    cell.viewModel = input.cellViewModel(for: indexPath)
    cell.viewModel.setOutput(cell)
    return cell
  }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    let screenSize = UIScreen.main.bounds
    let itemsPerRow = 2
    let interItemPadding = 10 * (itemsPerRow - 1)
    let collectionViewPadding = 16
    let totalPadding = CGFloat(interItemPadding + collectionViewPadding)
    let cellSquareSize = (screenSize.width - totalPadding) / CGFloat(itemsPerRow)
    return CGSize(width: cellSquareSize, height: cellSquareSize)
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
}

extension HomeViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    input.didSelectItem(at: indexPath)
  }
}

extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
    picker.dismiss(animated: true, completion: { [unowned self] in
      image.map { self.input.didAddImage($0) }
    })
  }
}
