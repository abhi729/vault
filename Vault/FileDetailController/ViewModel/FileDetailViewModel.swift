//
//  FileDetailViewModel.swift
//  Vault
//
//  Created by Abhishek Agarwal on 15/03/2021.
//  Copyright © 2021 Test. All rights reserved.
//

import Foundation

protocol FileDetailInput {
  func viewLoaded()
  mutating func setup(output: FileDetailViewOutput)
}

struct FileDetailViewModel: FileDetailInput {
  private weak var output: FileDetailViewOutput?
  private let file: File

  init(file: File) {
    self.file = file
  }

  mutating func setup(output: FileDetailViewOutput) {
    self.output = output
  }

  func viewLoaded() {
    output?.display(image: file.image)
  }
}
