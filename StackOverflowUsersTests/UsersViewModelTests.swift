//
//  UsersViewModelTests.swift
//  StackOverflowUsersTests
//
//  Created by Duarte Santos Lopes on 20/05/2026.
//

import XCTest
@testable import StackOverflowUsers

private extension User {
    static func mock(
        id: Int = 1,
        displayName: String = "Test User",
        reputation: Int = 100,
        isFollowed: Bool = false
    ) -> User {
        User(
            id: id,
            displayName: displayName,
            reputation: reputation,
            profileImageURL: nil,
            profileURL: nil,
            isFollowed: isFollowed
        )
    }
}

private enum TestError: Error {
    case somethingWentWrong
}

private final class MockUsersRepository: UsersRepositoryProtocol {
    var fetchTopUsersResult: Result<[User], Error> = .success([])
    var followedUserIDs: Set<Int> = []

    func fetchTopUsers() async throws -> [User] {
        switch fetchTopUsersResult {
        case .success(let users):
            return users
        case .failure(let error):
            throw error
        }
    }

    func follow(userID: Int) {
        followedUserIDs.insert(userID)
    }

    func unfollow(userID: Int) {
        followedUserIDs.remove(userID)
    }
}

@MainActor
final class UsersViewModelTests: XCTestCase {
    func testLoadUsersWhenRepositoryReturnsUsersSetsLoadedState() async {
        let repository = MockUsersRepository()
        let user = User.mock()
        
        repository.fetchTopUsersResult = .success([user])
        
        let viewModel = UsersViewModel(repository: repository)
        
        await viewModel.loadUsers()
        
        XCTAssertEqual(viewModel.state, .loaded([user]))
        XCTAssertEqual(viewModel.users, [user])
    }
    
    func testLoadUsersWhenRepositoryReturnsEmptyListSetsEmptyState() async {
        let repository = MockUsersRepository()
        repository.fetchTopUsersResult = .success([])
        
        let viewModel = UsersViewModel(repository: repository)
        
        await viewModel.loadUsers()
        
        XCTAssertEqual(viewModel.state, .empty(message: "No users found."))
        XCTAssertEqual(viewModel.users, [])
    }
    
    func testLoadUsersWhenRepositoryFailsSetsEmptyStateWithErrorMessage() async {
        let repository = MockUsersRepository()
        repository.fetchTopUsersResult = .failure(TestError.somethingWentWrong)
        
        let viewModel = UsersViewModel(repository: repository)
        
        await viewModel.loadUsers()
        
        XCTAssertEqual(viewModel.state, .empty(message: "Unable to load users. Please try again later."))
        XCTAssertEqual(viewModel.users, [])
    }
    
    func testToggleFollowWhenUserIsNotFollowedMarksUserAsFollowed() async {
        let repository = MockUsersRepository()
        let user = User.mock(isFollowed: false)
        
        repository.fetchTopUsersResult = .success([user])
        
        let viewModel = UsersViewModel(repository: repository)
        
        await viewModel.loadUsers()
        viewModel.toggleFollow(userID: user.id)
        
        XCTAssertTrue(repository.followedUserIDs.contains(user.id))
        XCTAssertEqual(viewModel.users.first?.isFollowed, true)
    }
    
    func testToggleFollowWhenUserIsFollowedMarksUserAsUnfollowed() async {
        let repository = MockUsersRepository()
        let user = User.mock(isFollowed: true)
        
        repository.followedUserIDs = [user.id]
        repository.fetchTopUsersResult = .success([user])
        
        let viewModel = UsersViewModel(repository: repository)
        
        await viewModel.loadUsers()
        viewModel.toggleFollow(userID: user.id)
        
        XCTAssertFalse(repository.followedUserIDs.contains(user.id))
        XCTAssertEqual(viewModel.users.first?.isFollowed, false)
    }
}
