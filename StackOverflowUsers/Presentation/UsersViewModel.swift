//
//  UsersViewModel.swift
//  StackOverflowUsers
//
//  Created by Duarte Santos Lopes on 19/05/2026.
//

import Foundation

private enum Constants {
    static let noUsersMessage = "No users found."
    static let loadUsersErrorMessage = "Unable to load users. Please try again later."
}

enum UsersViewState: Equatable {
    case idle
    case loading
    case loaded([User])
    case empty(message: String)
}

final class UsersViewModel {
    private let repository: UsersRepositoryProtocol
    
    private(set) var state: UsersViewState = .idle {
        didSet {
            onStateChange?(state)
        }
    }
    
    var users: [User] {
        guard case let .loaded(users) = state else {
            return []
        }
        
        return users
    }
    
    var onStateChange: ((UsersViewState) -> Void)?
    
    // MARK: - Init
    
    init(repository: UsersRepositoryProtocol = UsersRepository()) {
        self.repository = repository
    }
}

// MARK: - Public

extension UsersViewModel {
    func loadUsers() async {
        state = .loading
        
        do {
            let users = try await repository.fetchTopUsers()
            
            if users.isEmpty {
                state = .empty(message: Constants.noUsersMessage)
            } else {
                state = .loaded(users)
            }
        } catch {
            state = .empty(message: Constants.loadUsersErrorMessage)
        }
    }
    
    func toggleFollow(userID: Int) {
        guard let user = users.first(where: { $0.id == userID }) else {
            return
        }
        
        if user.isFollowed {
            unfollow(userID: userID)
        } else {
            follow(userID: userID)
        }
    }
}

// MARK: - Private

private extension UsersViewModel {
    func follow(userID: Int) {
        repository.follow(userID: userID)
        updateFollowState(userID: userID, isFollowed: true)
    }
    
    func unfollow(userID: Int) {
        repository.unfollow(userID: userID)
        updateFollowState(userID: userID, isFollowed: false)
    }
    
    func updateFollowState(userID: Int, isFollowed: Bool) {
        guard case let .loaded(users) = state else {
            return
        }
        
        let updatedUsers = users.map { user in
            guard user.id == userID else {
                return user
            }
            
            return User(
                id: user.id,
                displayName: user.displayName,
                reputation: user.reputation,
                profileImageURL: user.profileImageURL,
                profileURL: user.profileURL,
                isFollowed: isFollowed
            )
        }
        
        state = .loaded(updatedUsers)
    }
}
