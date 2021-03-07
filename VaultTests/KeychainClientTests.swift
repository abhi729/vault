//
//  VaultTests.swift
//  VaultTests
//
//  Created by Abhishek Agarwal on 07/03/2021.
//  Copyright © 2021 Test. All rights reserved.
//

import XCTest
@testable import Vault
import RxBlocking

class KeychainClientTests: XCTestCase {

  private var client: KeychainClient!
  private static let accountName = "abc"
  private static let password = "123"
  private static let incorrectAccountName = "xyz"

  override func setUp() {
    super.setUp()

    client = KeychainClientImpl.instance
  }

  override func tearDown() {
    super.tearDown()
    deleteCredentials()
  }

  @discardableResult
  private func deleteCredentials() -> MaterializedSequenceResult<Never> {
    let result = client
      .delete(account: KeychainClientTests.accountName)
      .toBlocking()
      .materialize()
    return result
  }

  @discardableResult
  private func saveCredentials() -> MaterializedSequenceResult<Never> {
    let result = client
      .save(password: KeychainClientTests.password, forAccount: KeychainClientTests.accountName)
      .toBlocking()
      .materialize()
    return result
  }

  @discardableResult
  private func getCredentials(forUser user: String = KeychainClientTests.accountName) -> MaterializedSequenceResult<String> {
    let result = client
      .getPassword(ofAccount: user)
      .toBlocking()
      .materialize()
    return result
  }

  func test_save_password_is_successful() {
    let result = saveCredentials()
    switch result {
    case .completed(elements: _):
      XCTAssert(true)
    default:
      XCTFail("Failed to save to keychain successfully")
    }
  }

  func test_get_password_retrieves_correctly_stored_credentials() {
    saveCredentials()
    let result = getCredentials()
    switch result {
    case .completed(elements: let passwords):
      XCTAssert(passwords.count == 1)
      XCTAssert(passwords[0] == KeychainClientTests.password)
    default:
      XCTFail("Failed to retrieve from keychain successfully")
    }
  }

  func test_get_password_returns_error_if_credentials_not_saved() {
    let result = getCredentials()
    switch result {
    case .completed(elements: _):
      XCTFail("No account added. Should have failed.")
    case .failed(elements: _, error: let error):
      var failedError: Error?
      if case KeychainError.failedToPerformAction = error {
        failedError = error
      }
      XCTAssertNotNil(failedError)
    }
  }

  func test_get_password_returns_error_if_credentials_not_present_for_provided_user() {
    saveCredentials()
    let result = getCredentials(forUser: KeychainClientTests.incorrectAccountName)
    switch result {
    case .completed(elements: _):
      XCTFail("Incorrect account provided. Should have failed.")
    case .failed(elements: _, error: let error):
      var failedError: Error?
      if case KeychainError.failedToPerformAction = error {
        failedError = error
      }
      XCTAssertNotNil(failedError)
    }
  }

  func test_delete_fails_if_no_account() {
    deleteCredentials()
    let result = deleteCredentials()
    switch result {
    case .completed(elements: _):
      XCTFail("Should have failed")
    case .failed(elements: _, error: let error):
      var failedError: Error?
      if case KeychainError.failedToPerformAction = error {
        failedError = error
      }
      XCTAssertNotNil(failedError)
    }
  }

  func test_delete_succeeds_if_account_exists() {
    saveCredentials()
    let result = deleteCredentials()
    switch result {
    case .completed(elements: _):
      XCTAssert(true)
    case .failed(elements: _, error: _):
      XCTFail("Should not have failed")
    }
  }

//  func test_match_password_is_unsuccessful_for_correct_account_and_incorrect_password() {
//    let client = KeychainClientImpl.instance
//    _ = client
//      .save(password: "123", forAccount: "abc")
//      .toBlocking()
//      .materialize()
//    let result = client
//      .matchPassword(ofAccount: "abc", with: "1234")
//      .toBlocking()
//      .materialize()
//    switch result {
//    case .completed(elements: _):
//      XCTFail("Should have failed as passwords are different")
//    case .failed(elements: _, error: let error):
//      var invalidCredentialsError: Error?
//      if case KeychainError.invalidCredentials = error {
//        invalidCredentialsError = error
//      }
//      XCTAssertNotNil(invalidCredentialsError)
//    }
//  }
//
//  func test_match_password_is_unsuccessful_for_incorrect_account_and_correct_password() {
//    let client = KeychainClientImpl.instance
//    _ = client
//      .save(password: "123", forAccount: "abc")
//      .toBlocking()
//      .materialize()
//    let result = client
//      .matchPassword(ofAccount: "xyz", with: "123")
//      .toBlocking()
//      .materialize()
//    switch result {
//    case .completed(elements: _):
//      XCTFail("Should have failed as account ids are different")
//    case .failed(elements: _, error: let error):
//      var failedToRetrieveError: Error?
//      if case KeychainError.failedToRetrieveData = error {
//        failedToRetrieveError = error
//      }
//      XCTAssertNotNil(failedToRetrieveError)
//    }
//  }

}
