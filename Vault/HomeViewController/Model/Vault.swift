//
//  Vault.swift
//  Vault
//
//  Created by Abhishek Agarwal on 08/03/2021.
//  Copyright © 2021 Test. All rights reserved.
//

import Foundation

class Vault: Codable {
  var albums: [Album]

  init(albums: [Album] = []) {
    self.albums = albums
  }

  // MARK: - CodingKeys
  private enum CodingKeys: String, CodingKey {
    case albums
  }

  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    albums = try values.decode([Album].self, forKey: .albums)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(albums, forKey: .albums)
  }
}
