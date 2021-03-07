//
//  UIViewController+TapDismiss.swift
//  Vault
//
//  Created by Abhishek Agarwal on 08/03/2021.
//  Copyright © 2021 Test. All rights reserved.
//

import UIKit

extension UIViewController {
  func hideKeyboardWhenTappedAround() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }

  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
}
