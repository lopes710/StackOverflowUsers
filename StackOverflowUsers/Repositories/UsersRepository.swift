//
//  UsersRepositories.swift
//  StackOverflowUsers
//
//  Created by Duarte Santos Lopes on 19/05/2026.
//

import Foundation

protocol UsersRepositoryProtocol {
    func fetchTopUsers() async throws -> [User]
    func follow(userID: Int)
    func unfollow(userID: Int)
}

final class UsersRepository: UsersRepositoryProtocol {
    private let networkClient: NetworkClientProtocol
    private let followedUsersStore: FollowedUsersStoreProtocol

    init(
        networkClient: NetworkClientProtocol = URLSessionNetworkClient(),
        followedUsersStore: FollowedUsersStoreProtocol = UserDefaultsFollowedUsersStore()
    ) {
        self.networkClient = networkClient
        self.followedUsersStore = followedUsersStore
    }

    func fetchTopUsers() async throws -> [User] {
        let request = try Endpoint.topUsers.urlRequest
        let response: UsersResponseDTO = try await networkClient.request(request)

        return response.items.map { userDTO in
            userDTO.toDomain(
                isFollowed: followedUsersStore.isFollowing(userID: userDTO.userId)
            )
        }
    }

    func follow(userID: Int) {
        followedUsersStore.follow(userID: userID)
    }

    func unfollow(userID: Int) {
        followedUsersStore.unfollow(userID: userID)
    }
}
