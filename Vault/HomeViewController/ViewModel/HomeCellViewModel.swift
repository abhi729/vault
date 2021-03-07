//
//  HomeCellViewModel.swift
//  Vault
//
//  Created by Abhishek Agarwal on 13/03/2021.
//  Copyright © 2021 Test. All rights reserved.
//

import Foundation

protocol HomeCellModelInput {
  var file: File { get }
  mutating func setOutput(_ output: HomeCollectionViewCellOutput)
}

struct HomeCellViewModel: HomeCellModelInput {
  let file: File
  
  private weak var output: HomeCollectionViewCellOutput? {
    didSet {
      output?.setupViews()
      if file.type == .directory {
        output?.setupName(file.name)
        output?.displayImage(Constants.placeHolderImage)
        output?.setImageViewContentMode(to: .scaleAspectFit)
      } else if file.type == .image {
        output?.hideNameLabel()
        output?.displayImage(file.image)
        output?.setImageViewContentMode(to: .scaleAspectFill)
      }
    }
  }

  init(file: File) {
    self.file = file
  }

  mutating func setOutput(_ output: HomeCollectionViewCellOutput) {
    self.output = output
  }
}
