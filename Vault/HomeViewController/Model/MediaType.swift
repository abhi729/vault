//
//  MediaType.swift
//  Vault
//
//  Created by Abhishek Agarwal on 08/03/2021.
//  Copyright © 2021 Test. All rights reserved.
//

import Foundation

enum MediaType: Int, Codable {
  case text = 0
  case image
  case video
  case directory
}
