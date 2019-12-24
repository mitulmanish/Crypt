//
//  Service.swift
//  Crypt
//
//  Created by Mitul Manish on 2/5/19.
//  Copyright © 2019 Mitul Manish. All rights reserved.
//

import Foundation
public struct Service {
    
    public static func fetch<DataType: Decodable>(
        urlRequest: URLRequest,
        completion: @escaping (Result<DataType, Error>) -> ()
    ) {
        URLSession.shared.get(request: urlRequest) { result in
            switch result {
            case .success(let data):
                do {
                    completion(.success(try JSONDecoder().decode(DataType.self, from: data)))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
