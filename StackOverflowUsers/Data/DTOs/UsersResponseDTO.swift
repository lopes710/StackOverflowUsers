//
//  UsersResponseDTO.swift
//  StackOverflowUsers
//
//  Created by Duarte Santos Lopes on 18/05/2026.
//

import Foundation

struct UsersResponseDTO: Decodable, Equatable {
    let items: [UserDTO]
}

struct UserDTO: Decodable, Equatable {
    let userId: Int
    let displayName: String
    let reputation: Int
    let profileImage: String?
    let link: String?

    // Alternative: These Codingkeys definition could be removed by configuring JSONDecoder.keyDecodingStrategy = .convertFromSnakeCase on decoding the json response.
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case displayName = "display_name"
        case reputation
        case profileImage = "profile_image"
        case link
    }
}

extension UserDTO {
    func toDomain(isFollowed: Bool) -> User {
        User(
            id: userId,
            displayName: displayName,
            reputation: reputation,
            profileImageURL: profileImage.flatMap(URL.init(string:)),
            profileURL: link.flatMap(URL.init(string:)),
            isFollowed: isFollowed
        )
    }
}
