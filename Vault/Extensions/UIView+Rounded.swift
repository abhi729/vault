//
//  UIView+Rounded.swift
//  Vault
//
//  Created by Abhishek Agarwal on 14/03/2021.
//  Copyright © 2021 Test. All rights reserved.
//

import UIKit

extension UIView {

  func rounded() {
    layer.cornerRadius = 16
    layer.masksToBounds = true
  }

}
