//
//  File.swift
//  Vault
//
//  Created by Abhishek Agarwal on 08/03/2021.
//  Copyright © 2021 Test. All rights reserved.
//

import Foundation
import UIKit
import Photos

class File: Codable, Equatable {
  let name: String
  let createdAt: TimeInterval
  let type: MediaType
  let path: String

  lazy var image: UIImage? = {
    return ImageRetriever.instance.getImage(at: path)
  }()

  init(name: String,
       createdAt: TimeInterval = Date().timeIntervalSince1970,
       type: MediaType,
       path: String) {
    self.name = name
    self.createdAt = createdAt
    self.type = type
    self.path = path
  }

  // MARK: - CodingKeys
  private enum CodingKeys: String, CodingKey {
    case name
    case createdAt
    case type
    case path
  }

  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    name = try values.decode(String.self, forKey: .name)
    createdAt = try values.decode(TimeInterval.self, forKey: .createdAt)
    type = try values.decode(MediaType.self, forKey: .type)
    path = try values.decode(String.self, forKey: .path)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(createdAt, forKey: .createdAt)
    try container.encode(type, forKey: .type)
    try container.encode(path, forKey: .path)
  }

  static func == (lhs: File, rhs: File) -> Bool {
    return lhs.name == rhs.name &&
      lhs.createdAt == rhs.createdAt &&
      lhs.path == rhs.path &&
      lhs.type == rhs.type
  }
}
