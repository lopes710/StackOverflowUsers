//
//  Endpoint.swift
//  StackOverflowUsers
//
//  Created by Duarte Santos Lopes on 18/05/2026.
//

import Foundation

struct Endpoint {
    enum Method: String {
        case get = "GET"
    }

    let path: String
    let method: Method
    let queryItems: [URLQueryItem]

    init(
        path: String,
        method: Method = .get,
        queryItems: [URLQueryItem] = []
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
    }
}

extension Endpoint {

    private var scheme: String {
        "https"
    }

    private var host: String {
        "api.stackexchange.com"
    }

    var url: URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = "/" + path
        components.queryItems = queryItems

        return components.url
    }

    var urlRequest: URLRequest {
        get throws {
            guard let url else {
                throw NetworkError.invalidURL
            }

            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.timeoutInterval = 30

            return request
        }
    }
}
