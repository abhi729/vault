//
//  AccountManagerTests.swift
//  VaultTests
//
//  Created by Abhishek Agarwal on 07/03/2021.
//  Copyright © 2021 Test. All rights reserved.
//

import XCTest
@testable import Vault
import RxBlocking

class AccountManagerTests: XCTestCase {

  private let client = MockKeychainClientImpl()
  private let validator = MockValidator()
  private let accountName = "abc"
  private let password = "123"
  private let pin = "1234"
  private let incorrectAccountName = "xyz"
  private let incorrectPassword = "456"
  private let incorrectPin = "5678"
  private var accountManager: AccountManager!

  override func setUp() {
    super.setUp()

    accountManager = AccountManagerImpl(keychainClient: client, validator: validator)
  }

  override func tearDown() {
    super.tearDown()

    client.reset()
    validator.reset()
  }

  func test_confirm_account_exists_does_not_return_error_if_account_exists() {
    client.mock(accounts: [accountName], accountsError: nil)
    let result = accountManager
      .confirmAnAccountExists()
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: _):
      XCTAssert(true)
    case .failed(elements: _, error: _):
      XCTFail("Should not have failed")
    }
  }

  func test_confirm_account_exists_returns_error_if_account_does_not_exists() {
    client.mock(accounts: [], accountsError: nil)
    let result = accountManager
      .confirmAnAccountExists()
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: _):
      XCTFail("Should have failed")
    case .failed(elements: _, error: let error):
      var failedError: Error?
      if case AuthenticationError.accountDoesNotExist = error {
        failedError = error
      }
      XCTAssertNotNil(failedError)
    }
  }

  func test_confirm_account_exists_returns_does_not_exist_error_if_keychain_retrieval_fails() {
    client.mock(accounts: [], accountsError: KeychainError.failedToPerformAction)
    let result = accountManager
      .confirmAnAccountExists()
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: _):
      XCTFail("Should have failed")
    case .failed(elements: _, error: let error):
      var failedError: Error?
      if case AuthenticationError.accountDoesNotExist = error {
        failedError = error
      }
      XCTAssertNotNil(failedError)
    }
  }

  func test_confirm_pin_created_does_not_return_error_if_account_and_pin_exists() {
    client.mock(accounts: [accountName, Constants.pinAttributeName], accountsError: nil)
    let result = accountManager
      .confirmPinCreated()
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: _):
      XCTAssert(true)
    case .failed(elements: _, error: _):
      XCTFail("Should not have failed")
    }
  }

  func test_confirm_pin_created_returns_error_if_account_exists_and_pin_does_not_exists() {
    client.mock(accounts: [accountName], accountsError: nil)
    let result = accountManager
      .confirmPinCreated()
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: _):
      XCTFail("Should have failed")
    case .failed(elements: _, error: let error):
      var failedError: Error?
      if case AuthenticationError.pinDoesNotExist = error {
        failedError = error
      }
      XCTAssertNotNil(failedError)
    }
  }

  func test_confirm_pin_created_returns_error_if_pin_does_not_exists() {
    client.mock(accounts: [], accountsError: nil)
    let result = accountManager
      .confirmPinCreated()
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: _):
      XCTFail("Should have failed")
    case .failed(elements: _, error: let error):
      var failedError: Error?
      if case AuthenticationError.pinDoesNotExist = error {
        failedError = error
      }
      XCTAssertNotNil(failedError)
    }
  }

  func test_confirm_pin_created_returns_does_not_exist_error_if_keychain_retrieval_fails() {
    client.mock(accounts: [], accountsError: KeychainError.failedToPerformAction)
    let result = accountManager
      .confirmPinCreated()
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: _):
      XCTFail("Should have failed")
    case .failed(elements: _, error: let error):
      var failedError: Error?
      if case AuthenticationError.pinDoesNotExist = error {
        failedError = error
      }
      XCTAssertNotNil(failedError)
    }
  }

  func test_signup_user_fails_if_invalid_email() {
    validator.mock(emailError: ValidationError.invalidCredentials)
    let result = accountManager
      .signUpUser(havingEmail: accountName, password: password)
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: _):
      XCTFail("Shoud have failed")
    case .failed(elements: _, error: let error):
      var failedError: Error?
      if case ValidationError.invalidCredentials = error {
        failedError = error
      }
      XCTAssertNotNil(failedError)
    }
  }

  func test_signup_user_fails_if_invalid_password() {
    validator.mock(passwordError: ValidationError.invalidCredentials)
    let result = accountManager
      .signUpUser(havingEmail: accountName, password: password)
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: _):
      XCTFail("Shoud have failed")
    case .failed(elements: _, error: let error):
      var failedError: Error?
      if case ValidationError.invalidCredentials = error {
        failedError = error
      }
      XCTAssertNotNil(failedError)
    }
  }

  func test_signup_user_fails_if_user_already_in_keychain() {
    client.mock(password: password, passwordError: nil, saveError: KeychainError.failedToPerformAction)
    let result = accountManager
      .signUpUser(havingEmail: accountName, password: password)
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: _):
      XCTFail("Shoud have failed")
    case .failed(elements: _, error: let error):
      var failedError: Error?
      if case AuthenticationError.userAlreadyExists = error {
        failedError = error
      }
      XCTAssertNotNil(failedError)
    }
  }

  func test_signup_user_fails_if_user_not_in_keychain_and_save_fails() {
    client.mock(passwordError: KeychainError.failedToPerformAction, saveError: KeychainError.failedToPerformAction)
    let result = accountManager
      .signUpUser(havingEmail: accountName, password: password)
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: _):
      XCTFail("Shoud have failed")
    case .failed(elements: _, error: let error):
      var failedError: Error?
      if case KeychainError.failedToPerformAction = error {
        failedError = error
      }
      XCTAssertNotNil(failedError)
    }
  }

  func test_signup_user_succeeds_if_user_not_in_keychain_and_save_succeeds() {
    client.mock(passwordError: KeychainError.failedToPerformAction)
    let result = accountManager
      .signUpUser(havingEmail: accountName, password: password)
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: _):
      XCTAssert(true)
    case .failed(elements: _, error: _):
      XCTFail("Should not have failed")
    }
  }

  func test_login_user_fails_if_invalid_email() {
    validator.mock(emailError: ValidationError.invalidCredentials)
    let result = accountManager
      .loginUser(havingEmail: accountName, password: password)
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: _):
      XCTFail("Shoud have failed")
    case .failed(elements: _, error: let error):
      var failedError: Error?
      if case ValidationError.invalidCredentials = error {
        failedError = error
      }
      XCTAssertNotNil(failedError)
    }
  }

  func test_login_user_fails_if_invalid_password() {
    validator.mock(passwordError: ValidationError.invalidCredentials)
    let result = accountManager
      .loginUser(havingEmail: accountName, password: password)
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: _):
      XCTFail("Shoud have failed")
    case .failed(elements: _, error: let error):
      var failedError: Error?
      if case ValidationError.invalidCredentials = error {
        failedError = error
      }
      XCTAssertNotNil(failedError)
    }
  }

  func test_login_user_fails_for_wrong_email_or_password() {
    client.mock(password: password, passwordError: nil)
    let result = accountManager
      .loginUser(havingEmail: accountName, password: incorrectPassword)
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: _):
      XCTFail("Shoud have failed")
    case .failed(elements: _, error: let error):
      var failedError: Error?
      if case AuthenticationError.invalidCredentials = error {
        failedError = error
      }
      XCTAssertNotNil(failedError)
    }
  }

  func test_login_user_succeeds_for_correct_credentials() {
    client.mock(password: password, passwordError: nil)
    let result = accountManager
      .loginUser(havingEmail: accountName, password: password)
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: _):
      XCTAssert(true)
    case .failed(elements: _, error: _):
      XCTFail("Should have succeeded")
    }
  }

  func test_create_pin_fails_if_invalid_pin() {
    validator.mock(passwordError: ValidationError.invalidCredentials)
    let result = accountManager
      .createPin(pin)
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: _):
      XCTFail("Shoud have failed")
    case .failed(elements: _, error: let error):
      var failedError: Error?
      if case ValidationError.invalidCredentials = error {
        failedError = error
      }
      XCTAssertNotNil(failedError)
    }
  }

  func test_create_pin_fails_if_pin_already_in_keychain() {
    client.mock(password: password, passwordError: nil, saveError: KeychainError.failedToPerformAction)
    let result = accountManager
      .createPin(pin)
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: _):
      XCTFail("Shoud have failed")
    case .failed(elements: _, error: let error):
      var failedError: Error?
      if case AuthenticationError.userAlreadyExists = error {
        failedError = error
      }
      XCTAssertNotNil(failedError)
    }
  }

  func test_create_pin_fails_if_pin_not_in_keychain_and_save_fails() {
    client.mock(passwordError: KeychainError.failedToPerformAction, saveError: KeychainError.failedToPerformAction)
    let result = accountManager
      .createPin(pin)
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: _):
      XCTFail("Shoud have failed")
    case .failed(elements: _, error: let error):
      var failedError: Error?
      if case KeychainError.failedToPerformAction = error {
        failedError = error
      }
      XCTAssertNotNil(failedError)
    }
  }

  func test_create_pin_succeeds_if_pin_not_in_keychain_and_save_succeeds() {
    client.mock(passwordError: KeychainError.failedToPerformAction)
    let result = accountManager
      .createPin(pin)
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: _):
      XCTAssert(true)
    case .failed(elements: _, error: _):
      XCTFail("Should not have failed")
    }
  }

  func test_match_pin_fails_if_invalid_pin() {
    validator.mock(passwordError: ValidationError.invalidCredentials)
    let result = accountManager
      .matchPin(pin)
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: _):
      XCTFail("Shoud have failed")
    case .failed(elements: _, error: let error):
      var failedError: Error?
      if case ValidationError.invalidCredentials = error {
        failedError = error
      }
      XCTAssertNotNil(failedError)
    }
  }

  func test_match_pin_fails_for_wrong_pin() {
    client.mock(password: pin, passwordError: nil)
    let result = accountManager
      .matchPin(incorrectPin)
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: _):
      XCTFail("Shoud have failed")
    case .failed(elements: _, error: let error):
      var failedError: Error?
      if case AuthenticationError.invalidCredentials = error {
        failedError = error
      }
      XCTAssertNotNil(failedError)
    }
  }

  func test_match_pin_succeeds_for_correct_pin() {
    client.mock(password: pin, passwordError: nil)
    let result = accountManager
      .matchPin(pin)
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: _):
      XCTAssert(true)
    case .failed(elements: _, error: _):
      XCTFail("Should have succeeded")
    }
  }

}
