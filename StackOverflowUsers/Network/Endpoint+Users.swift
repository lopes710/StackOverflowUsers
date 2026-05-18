//
//  Endpoint+Users.swift
//  StackOverflowUsers
//
//  Created by Duarte Santos Lopes on 18/05/2026.
//

import Foundation

extension Endpoint {

    static var topUsers: Self {
        Endpoint(
            path: "2.2/users",
            queryItems: [
                URLQueryItem(name: "page", value: "1"),
                URLQueryItem(name: "pagesize", value: "20"),
                URLQueryItem(name: "order", value: "desc"),
                URLQueryItem(name: "sort", value: "reputation"),
                URLQueryItem(name: "site", value: "stackoverflow")
            ]
        )
    }
}
