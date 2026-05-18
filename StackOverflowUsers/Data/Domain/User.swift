//
//  User.swift
//  StackOverflowUsers
//
//  Created by Duarte Santos Lopes on 18/05/2026.
//

import Foundation

struct User: Equatable {
    let id: Int
    let displayName: String
    let reputation: Int
    let profileImageURL: URL?
    let profileURL: URL?
    let isFollowed: Bool
}
