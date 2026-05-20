//
//  UsersRepositoryTests.swift
//  StackOverflowUsersTests
//
//  Created by Duarte Santos Lopes on 20/05/2026.
//

import XCTest
@testable import StackOverflowUsers

private final class MockNetworkClient: NetworkClientProtocol {
    func request<ResponseBody: Decodable>(_ request: URLRequest) async throws -> ResponseBody {
        return UsersResponseDTO(
            items: [
                UserDTO(
                    userId: 123,
                    displayName: "user1",
                    reputation: 100,
                    profileImage: nil,
                    link: nil
                ),
                UserDTO(
                    userId: 321,
                    displayName: "user2",
                    reputation: 500,
                    profileImage: nil,
                    link: nil
                )
            ]
        ) as! ResponseBody
    }
}

private final class MockFollowedUsersStore: FollowedUsersStoreProtocol {
    var followedIDs: Set<Int> = []

    func followedUserIDs() -> Set<Int> {
        followedIDs
    }

    func isFollowing(userID: Int) -> Bool {
        followedIDs.contains(userID)
    }

    func follow(userID: Int) {
        followedIDs.insert(userID)
    }

    func unfollow(userID: Int) {
        followedIDs.remove(userID)
    }
}

@MainActor
final class UsersRepositoryTests: XCTestCase {
    
    func testFetchTopUsersMapsDTOsToUsers() async throws {
        let mockFollowedUsersStore = MockFollowedUsersStore()
        
        let usersRepository = UsersRepository(
            networkClient: MockNetworkClient(),
            followedUsersStore: mockFollowedUsersStore
        )
        
        let users = try await usersRepository.fetchTopUsers()
        
        XCTAssertEqual(users.count, 2)
        
        let user1 = users[0]
        let user2 = users[1]
        
        XCTAssertEqual(user1.id, 123)
        XCTAssertEqual(user1.displayName, "user1")
        XCTAssertEqual(user1.reputation, 100)
        XCTAssertEqual(user1.isFollowed, false)

        XCTAssertEqual(user2.id, 321)
        XCTAssertEqual(user2.displayName, "user2")
        XCTAssertEqual(user2.reputation, 500)
        XCTAssertEqual(user2.isFollowed, false)
    }
    
    func testFetchTopUsersMarksFollowedUsersFromStore() async throws {
        let mockFollowedUsersStore = MockFollowedUsersStore()
        mockFollowedUsersStore.followedIDs = [321]
        
        let usersRepository = UsersRepository(
            networkClient: MockNetworkClient(),
            followedUsersStore: mockFollowedUsersStore
        )
        
        let users = try await usersRepository.fetchTopUsers()
        
        XCTAssertEqual(users[0].isFollowed, false)
        XCTAssertEqual(users[1].isFollowed, true)
    }
    
    func testFollowUserFromStore() async throws {
        let mockFollowedUsersStore = MockFollowedUsersStore()
        
        let usersRepository = UsersRepository(
            networkClient: MockNetworkClient(),
            followedUsersStore: mockFollowedUsersStore
        )
        
        usersRepository.follow(userID: 321)
        
        XCTAssertEqual(mockFollowedUsersStore.followedIDs, [321])
    }
    
    func testUnfollowUserFromStore() async throws {
        let mockFollowedUsersStore = MockFollowedUsersStore()
        mockFollowedUsersStore.followedIDs = [321]
        
        let usersRepository = UsersRepository(
            networkClient: MockNetworkClient(),
            followedUsersStore: mockFollowedUsersStore
        )
        
        usersRepository.unfollow(userID: 321)
        
        XCTAssertEqual(mockFollowedUsersStore.followedIDs, [])
    }
}
