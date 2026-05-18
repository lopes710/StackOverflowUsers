//
//  UserDefaultsFollowedUsersStore.swift
//  StackOverflowUsers
//
//  Created by Duarte Santos Lopes on 19/05/2026.
//

import Foundation

protocol FollowedUsersStoreProtocol {
    func followedUserIDs() -> Set<Int>
    func isFollowing(userID: Int) -> Bool
    func follow(userID: Int)
    func unfollow(userID: Int)
}

final class UserDefaultsFollowedUsersStore: FollowedUsersStoreProtocol {
    private let userDefaults: UserDefaults
    private static let followedKey = "followed_user_ids"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func followedUserIDs() -> Set<Int> {
        let ids = userDefaults.array(forKey: Self.followedKey) as? [Int] ?? []
        return Set(ids)
    }

    func isFollowing(userID: Int) -> Bool {
        followedUserIDs().contains(userID)
    }

    func follow(userID: Int) {
        var ids = followedUserIDs()
        ids.insert(userID)
        save(ids)
    }

    func unfollow(userID: Int) {
        var ids = followedUserIDs()
        ids.remove(userID)
        save(ids)
    }

    private func save(_ ids: Set<Int>) {
        userDefaults.set(Array(ids), forKey: Self.followedKey)
    }
}
