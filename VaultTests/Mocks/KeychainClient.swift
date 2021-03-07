//
//  KeychainClient.swift
//  VaultTests
//
//  Created by Abhishek Agarwal on 07/03/2021.
//  Copyright © 2021 Test. All rights reserved.
//

import Foundation
@testable import Vault
import RxSwift

class MockKeychainClientImpl: KeychainClient {
  private var accounts = [String]()
  private var password: String?
  private var saveError: Error?
  private var accountsError: Error?
  private var passwordError: Error?
  private var deleteError: Error?

  func mock(accounts: [String] = [],
            accountsError: Error? = nil,
            password: String? = nil,
            passwordError: Error? = nil,
            saveError: Error? = nil,
            deleteError: Error? = nil) {
    self.password = password
    self.accounts = accounts
    self.saveError = saveError
    self.accountsError = accountsError
    self.passwordError = passwordError
    self.deleteError = deleteError
  }

  func reset() {
    mock()
  }

  func save(password: String, forAccount id: String) -> Completable {
    return Completable.deferred { [unowned self] in
      return self.saveError == nil ? .empty() : .error(self.saveError!)
    }
  }

  func getAccounts() -> Single<[String]> {
    return Single.deferred { [unowned self] in
      return self.accountsError == nil ? .just(self.accounts) : .error(self.accountsError!)
    }
  }

  func getPassword(ofAccount id: String) -> Single<String> {
    return Single.deferred { [unowned self] in
      return self.passwordError == nil ? .just(self.password!) : .error(self.passwordError!)
    }
  }

  func delete(account id: String) -> Completable {
    return Completable.deferred { [unowned self] in
      return self.deleteError == nil ? .empty() : .error(self.deleteError!)
    }
  }

}
