//
//  URLSession+Result.swift
//  Crypt
//
//  Created by Mitul Manish on 2/5/19.
//  Copyright © 2019 Mitul Manish. All rights reserved.
//

import Foundation

public typealias URLSessionNetworkResult = Result<Data, Error>

public extension URLSession {
    private func getResult(data: Data?, response: URLResponse?, error: Error?) -> URLSessionNetworkResult {
        switch (data, response, error) {
        case let (_, _, error?):
            return .failure(error)
        case let (data?, response as HTTPURLResponse, _)
            where NetworkingError.from(httpCode: response.statusCode) == .none:
            return .success(data)
        case let (_, response as HTTPURLResponse, .none):
            return .failure(NetworkingError.from(httpCode: response.statusCode) ?? NetworkingError.unknown)
        case (_, _, .none):
            return .failure(NetworkingError.noResponse)
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
