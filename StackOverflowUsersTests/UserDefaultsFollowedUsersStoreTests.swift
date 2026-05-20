//
//  UserDefaultsFollowedUsersStoreTests.swift
//  StackOverflowUsersTests
//
//  Created by Duarte Santos Lopes on 20/05/2026.
//

import XCTest
@testable import StackOverflowUsers

final class UserDefaultsFollowedUsersStoreTests: XCTestCase {
    private let userDefaultsSuiteName = "UserDefaultsFollowedUsersStoreTests"
    private var userDefaults: UserDefaults!
    private var store: UserDefaultsFollowedUsersStore!
    
    override func setUp() {
        super.setUp()
        
        userDefaults = UserDefaults(suiteName: userDefaultsSuiteName)
        userDefaults.removePersistentDomain(forName: userDefaultsSuiteName)
        
        store = UserDefaultsFollowedUsersStore(userDefaults: userDefaults)
    }
    
    override func tearDown() {
        userDefaults.removePersistentDomain(forName: userDefaultsSuiteName)
        
        store = nil
        userDefaults = nil
        
        super.tearDown()
    }
    
    func testFollowAddsUserID() {
        store.follow(userID: 123)
        
        XCTAssertTrue(store.isFollowing(userID: 123))
        XCTAssertEqual(store.followedUserIDs(), [123])
    }
    
    func testUnfollowRemovesUserID() {
        store.follow(userID: 123)
        store.unfollow(userID: 123)
        
        XCTAssertFalse(store.isFollowing(userID: 123))
        XCTAssertEqual(store.followedUserIDs(), [])
    }
    
    func testFollowMultipleUsersStoresAllIDs() {
        store.follow(userID: 123)
        store.follow(userID: 321)
        
        XCTAssertTrue(store.isFollowing(userID: 123))
        XCTAssertTrue(store.isFollowing(userID: 321))
        XCTAssertEqual(store.followedUserIDs(), [123, 321])
    }
}
