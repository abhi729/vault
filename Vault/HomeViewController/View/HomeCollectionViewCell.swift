//
//  HomeCollectionViewCell.swift
//  Vault
//
//  Created by Abhishek Agarwal on 13/03/2021.
//  Copyright © 2021 Test. All rights reserved.
//

import UIKit

protocol HomeCollectionViewCellOutput: class {
  func setupViews()
  func displayImage(_ image: UIImage?)
  func setupName(_ name: String)
  func hideNameLabel()
  func setImageViewContentMode(to mode: UIView.ContentMode)
}

class HomeCollectionViewCell: UICollectionViewCell, HomeCollectionViewCellOutput {
  @IBOutlet weak var albumView: UIView!
  @IBOutlet weak var coverImageView: UIImageView!
  @IBOutlet weak var albumNameLabel: UILabel!
  @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!

  static let identifier = "HomeCollectionViewCell"

  var viewModel: HomeCellModelInput!

  override func prepareForReuse() {
    super.prepareForReuse()

    resetCover()
    hideNameLabel()
  }

  func setupViews() {
    albumView.rounded()
    hideNameLabel()
  }

  func displayImage(_ image: UIImage?) {
    coverImageView.image = image
  }

  func setupName(_ name: String) {
    albumNameLabel.isHidden = false
    albumNameLabel.text = name
    stackViewBottomConstraint.constant = 8
  }

  private func resetCover() {
    coverImageView.contentMode = .scaleAspectFit
    coverImageView.image = Constants.placeHolderImage
  }

  func hideNameLabel() {
    albumNameLabel.isHidden = true
    stackViewBottomConstraint.constant = 0
  }

  func setImageViewContentMode(to mode: UIView.ContentMode) {
    coverImageView.contentMode = mode
  }

}
