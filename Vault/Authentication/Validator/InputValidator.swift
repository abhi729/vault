//
//  InputValidator.swift
//  Vault
//
//  Created by Abhishek Agarwal on 07/03/2021.
//  Copyright © 2021 Test. All rights reserved.
//

import Foundation
import RxSwift

enum ValidationError: Error {
  case invalidCredentials
}

protocol InputValidator {
  func validate(email: String) -> Completable
  func validate(password: String) -> Completable
}

struct InputValidatorImpl: InputValidator {
  func validate(email: String) -> Completable {
    return Completable.deferred {
      let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
      let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
      return emailPred.evaluate(with: email) ? .empty() : .error(ValidationError.invalidCredentials)
    }
  }

  func validate(password: String) -> Completable {
    return Completable.deferred {
      return password.count >= 4 ? .empty() : .error(ValidationError.invalidCredentials)
    }
  }

}
