//
//  PersistanceManagerImpl.swift
//  VaultTests
//
//  Created by Abhishek Agarwal on 08/03/2021.
//  Copyright © 2021 Test. All rights reserved.
//

import XCTest
@testable import Vault
import RxBlocking

class PersistanceManagerTests: XCTestCase {

  var manager: PersistanceManager!

  private let album1 = "Album1"
  private let album2 = "Album2"

  override func setUp() {
    super.setUp()

    manager = PersistanceManagerImpl()
  }

  override func tearDown() {
    super.tearDown()

    cleanupAlbums([album1, album2])
  }

  private func cleanupAlbums(_ albums: [String]) {
    albums.forEach {
      _ = manager.deleteAlbum(havingName: $0)
        .toBlocking()
        .materialize()
    }
  }

  @discardableResult
  private func createAlbum(_ album: String) -> MaterializedSequenceResult<Vault> {
    let result = manager
      .createAlbum(havingName: album)
      .toBlocking()
      .materialize()
    return result
  }

  func test_create_album_succeeds_if_not_present() {
    let result = createAlbum(album1)
    switch result {
    case .completed(elements: _):
      XCTAssert(true)
    case .failed(elements: _, error: _):
      XCTFail("Should have succeeded")
    }
  }

  func test_get_albums_returns_created_albums() {
    createAlbum(album1)
    createAlbum(album2)
    let result = manager.listAlbums()
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: let albums):
      XCTAssert(albums.count > 0)
    case .failed(elements: _, error: let error):
      print(error)
      XCTFail("Should have succeeded")
    }
  }

  func test_delete_deletes_the_given_album() {
    createAlbum(album1)
    let result = manager.deleteAlbum(havingName: album1)
      .toBlocking()
      .materialize()
    switch result {
    case .completed(elements: _):
      XCTAssert(true)
    case .failed(elements: _, error: _):
      XCTFail("Should not have failed")
    }
  }
}
