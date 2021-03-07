//
//  FileDetailViewController.swift
//  Vault
//
//  Created by Abhishek Agarwal on 15/03/2021.
//  Copyright © 2021 Test. All rights reserved.
//

import UIKit

protocol FileDetailViewInput: class {
  func setupViewModel(_ model: FileDetailInput)
}

protocol FileDetailViewOutput: class {
  func display(image: UIImage?)
}

class FileDetailViewController: UIViewController, FileDetailViewOutput, FileDetailViewInput {
  @IBOutlet weak var fileImageView: UIImageView!

  private var input: FileDetailInput!

  override func viewDidLoad() {
    super.viewDidLoad()
    input.viewLoaded()
  }

  func setupViewModel(_ model: FileDetailInput) {
    input = model
    input.setup(output: self)
  }

  func display(image: UIImage?) {
    fileImageView.image = image
  }
}
