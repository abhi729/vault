//
//  Album.swift
//  Vault
//
//  Created by Abhishek Agarwal on 08/03/2021.
//  Copyright © 2021 Test. All rights reserved.
//

import Foundation

class Album: File {
  var files: [File]

  init(name: String,
       createdAt: TimeInterval = Date().timeIntervalSince1970,
       path: String,
       files: [File] = []) {
    self.files = files
    super.init(name: name, createdAt: createdAt, type: .directory, path: path)
  }

  // MARK: - CodingKeys
  private enum CodingKeys: String, CodingKey {
    case files
  }

  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    files = try values.decode([File].self, forKey: .files)
    try super.init(from: decoder)
  }

  override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(files, forKey: .files)
    try super.encode(to: encoder)
  }
}
