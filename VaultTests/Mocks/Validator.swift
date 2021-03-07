//
//  Validator.swift
//  VaultTests
//
//  Created by Abhishek Agarwal on 07/03/2021.
//  Copyright © 2021 Test. All rights reserved.
//

import Foundation
@testable import Vault
import RxSwift

class MockValidator: InputValidator {
  var emailError: Error?
  var passwordError: Error?

  func mock(emailError: Error? = nil, passwordError: Error? = nil) {
    self.emailError = emailError
    self.passwordError = passwordError
  }

  func reset() {
    mock()
  }

  func validate(email: String) -> Completable {
    return Completable.deferred { [unowned self] in
      return self.emailError == nil ? .empty() : .error(self.emailError!)
    }
  }

  func validate(password: String) -> Completable {
    return Completable.deferred { [unowned self] in
      return self.passwordError == nil ? .empty() : .error(self.passwordError!)
    }  }
}
