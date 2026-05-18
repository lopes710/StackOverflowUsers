//
//  NetworkError.swift
//  StackOverflowUsers
//
//  Created by Duarte Santos Lopes on 18/05/2026.
//

import Foundation

enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case decodingError
    case httpError(statusCode: Int)
    case unknown(String)
}
