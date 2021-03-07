//
//  KeychainClient.swift
//  Vault
//
//  Created by Abhishek Agarwal on 07/03/2021.
//  Copyright © 2021 Test. All rights reserved.
//

import Foundation
import Security
import RxSwift

enum KeychainError: Error {
  case failedToPerformAction
}

protocol KeychainClient {
  func save(password: String, forAccount  id: String) -> Completable
  func getAccounts() -> Single<[String]>
  func getPassword(ofAccount id: String) -> Single<String>
  func delete(account id: String) -> Completable
}

class KeychainClientImpl: KeychainClient {
  private init() {}

  static let instance = KeychainClientImpl()

  func save(password: String, forAccount id: String) -> Completable {
    return Completable.deferred { [unowned self] in
      let item = self.createItem(forPassword: password, ofAccount: id)
      let status = SecItemAdd(item, nil)
      if status == 0 {
        return .empty()
      } else {
        return .error(KeychainError.failedToPerformAction)
      }
    }
  }

  func getAccounts() -> Single<[String]> {
    return getAllAccounts()
      .map { $0.compactMap { $0[kSecAttrAccount] as? String } }
  }

  func getPassword(ofAccount id: String) -> Single<String> {
    return getAllAccounts()
      .flatMap { credentials in
        guard let credential = credentials.first(where: { $0[kSecAttrAccount] as? String == id }),
          let passwordData = credential[kSecValueData] as? Data,
          let password = String.init(data: passwordData, encoding: .utf8)
        else {
          return .error(KeychainError.failedToPerformAction)
        }
        return .just(password)
    }
  }

  func delete(account id: String) -> Completable {
    return Completable.deferred { [unowned self] in
      let item = self.deleteItem(forAccount: id)
      let status = SecItemDelete(item)
      if status == 0 {
        return .empty()
      } else {
        return .error(KeychainError.failedToPerformAction)
      }
    }
  }

  private func getAllAccounts() -> Single<[NSDictionary]> {
    return Single.deferred { [unowned self] in
      let item = self.getItem()
      var result: AnyObject?
      _ = SecItemCopyMatching(item, &result)
      guard result != nil,
        let credentials = result as? [NSDictionary] else {
        return .error(KeychainError.failedToPerformAction)
      }
      return .just(credentials)
    }
  }

  private func createItem(forPassword password: String, ofAccount  id: String) -> CFDictionary {
    return [
      kSecValueData: password.data(using: .utf8)!,
      kSecAttrAccount: id,
      kSecAttrServer: Constants.serverName,
      kSecClass: kSecClassInternetPassword
    ] as CFDictionary
  }

  private func getItem() -> CFDictionary {
    return [
      kSecClass: kSecClassInternetPassword,
      kSecAttrServer: Constants.serverName,
      kSecReturnAttributes: true,
      kSecReturnData: true,
      kSecMatchLimit: 2
    ] as CFDictionary
  }

  private func deleteItem(forAccount id: String) -> CFDictionary {
    return [
      kSecClass: kSecClassInternetPassword,
      kSecAttrServer: Constants.serverName,
      kSecAttrAccount: id,
    ] as CFDictionary
  }
}
