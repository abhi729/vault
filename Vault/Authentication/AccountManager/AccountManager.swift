//
//  AccountManager.swift
//  Vault
//
//  Created by Abhishek Agarwal on 07/03/2021.
//  Copyright © 2021 Test. All rights reserved.
//

import Foundation
import RxSwift

enum AuthenticationError: Error {
  case invalidCredentials
  case accountDoesNotExist
  case pinDoesNotExist
  case userAlreadyExists
}

protocol AccountManager {
  func confirmAnAccountExists() -> Completable
  func confirmPinCreated() -> Completable

  func signUpUser(havingEmail email: String, password: String) -> Completable
  func loginUser(havingEmail email: String, password: String) -> Completable

  func createPin(_ pin: String) -> Completable
  func matchPin(_ pin: String) -> Completable
}

class AccountManagerImpl: AccountManager {

  private let keychainClient: KeychainClient
  private let validator: InputValidator

  init(keychainClient: KeychainClient = KeychainClientImpl.instance,
       validator: InputValidator = InputValidatorImpl()) {
    self.keychainClient = keychainClient
    self.validator = validator
  }

  func confirmAnAccountExists() -> Completable {
    return keychainClient
      .getAccounts()
      .catchError { _ in .just([]) }
      .flatMapCompletable { accounts in
        return (!accounts.isEmpty) ? .empty() : .error(AuthenticationError.accountDoesNotExist)
    }
  }

  func confirmPinCreated() -> Completable {
    return keychainClient
      .getAccounts()
      .catchError { _ in .just([]) }
      .flatMapCompletable { accounts in
        let pin = accounts.filter { $0 == Constants.pinAttributeName }
        return pin.count != 0 ? .empty() : .error(AuthenticationError.pinDoesNotExist)
    }
  }

  func signUpUser(havingEmail email: String, password: String) -> Completable {
    return validator
      .validate(email: email)
      .andThen(validator.validate(password: password))
      .andThen(keychainClient.getPassword(ofAccount: email))
      .flatMapCompletable { _ in
        return .error(AuthenticationError.userAlreadyExists)
      }.catchError { [unowned self] error in
        guard case KeychainError.failedToPerformAction = error else {
          return .error(error)
        }
        return self.keychainClient.save(password: password, forAccount: email)
    }
  }

  func loginUser(havingEmail email: String, password: String) -> Completable {
    return validator
      .validate(email: email)
      .andThen(validator.validate(password: password))
      .andThen(matchPassword(ofAccount: email, with: password))
  }

  func createPin(_ pin: String) -> Completable {
    return signUpUser(havingEmail: Constants.pinAttributeName, password: pin)
  }

  func matchPin(_ pin: String) -> Completable {
    return validator
      .validate(password: pin)
      .andThen(matchPassword(ofAccount: Constants.pinAttributeName, with: pin))
  }

  private func matchPassword(ofAccount id: String, with text: String) -> Completable {
    return keychainClient
      .getPassword(ofAccount: id)
      .flatMapCompletable { $0 == text ? .empty() : .error(AuthenticationError.invalidCredentials) }
  }
}
