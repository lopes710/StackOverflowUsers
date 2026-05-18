//
//  URLSessionNetworkClient.swift
//  StackOverflowUsers
//
//  Created by Duarte Santos Lopes on 19/05/2026.
//

import Foundation

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

final class URLSessionNetworkClient: NetworkClientProtocol {
    private let urlSession: URLSessionProtocol
    private let jsonDecoder: JSONDecoder

    init(
        urlSession: URLSessionProtocol = URLSession.shared,
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
    }

    func request<ResponseBody: Decodable>(_ request: URLRequest) async throws -> ResponseBody {
        do {
            let (data, response) = try await urlSession.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
            }

            do {
                return try jsonDecoder.decode(ResponseBody.self, from: data)
            } catch {
                throw NetworkError.decodingError
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error.localizedDescription)
        }
    }
}
