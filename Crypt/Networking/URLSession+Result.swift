//
//  URLSession+Result.swift
//  Crypt
//
//  Created by Mitul Manish on 2/5/19.
//  Copyright © 2019 Mitul Manish. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noResponse
    case invalidCredentials
    case clientError
    case serverError
    case unknown
    
    static func from(httpCode: Int) -> NetworkError? {
        switch httpCode {
        case 200...299, 300...399:
            return .none
        case 400, 401:
            return .invalidCredentials
        case 402...499:
            return .clientError
        case 500...599:
            return .serverError
        default:
            return .unknown
        }
    }
}

public typealias URLSessionNetworkResult = Result<Data, Error>

extension URLSession {
    private func getResult(data: Data?, response: URLResponse?, error: Error?) -> URLSessionNetworkResult {
        switch (data, response, error) {
        case let (_, _, error?):
            return .failure(error)
        case let (data?, response as HTTPURLResponse, _)
            where NetworkError.from(httpCode: response.statusCode) == .none:
            return .success(data)
        case let (_, response as HTTPURLResponse, .none):
            return .failure(NetworkError.from(httpCode: response.statusCode) ?? NetworkError.unknown)
        case (_, _, .none):
            return .failure(NetworkError.noResponse)
        }
    }
    
    func get(request: URLRequest, result: @escaping (URLSessionNetworkResult) -> Void) {
        dataTask(with: request) { [unowned self] data, response, error in
            result(self.getResult(data: data, response: response, error: error))
        }.resume()
    }
    
    func get(url: URL, result: @escaping (URLSessionNetworkResult) -> Void) {
        dataTask(with: url) { [unowned self] data, response, error in
            result(self.getResult(data: data, response: response, error: error))
        }.resume()
    }
}
