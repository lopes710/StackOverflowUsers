//
//  NetworkClientProtocol.swift
//  StackOverflowUsers
//
//  Created by Duarte Santos Lopes on 18/05/2026.
//

import Foundation

protocol NetworkClientProtocol {
    func request<ResponseBody: Decodable>(_ request: URLRequest) async throws -> ResponseBody
}
