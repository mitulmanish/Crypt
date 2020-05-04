import Foundation
import Combine

enum APIFailure: Error {
    case invalidNetworkResponse
}

public struct NetworkingPublisher {
    
    public static func dataPublisher<DataType: Decodable>(
        url: URL,
        decoder: JSONDecoder = JSONDecoder()
    ) -> AnyPublisher<DataType, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
        .asPublisher(decoder: decoder)
    }
    
    public static func dataPublisher<DataType: Decodable>(
        urlRequest: URLRequest,
        decoder: JSONDecoder = JSONDecoder()
    ) -> AnyPublisher<DataType, Error> {
        URLSession.shared.dataTaskPublisher(for: urlRequest)
        .asPublisher(decoder: decoder)
    }
}

private extension URLSession.DataTaskPublisher {
    func asPublisher<DataType: Decodable>(decoder: JSONDecoder)
        -> AnyPublisher<DataType, Error> {
        tryMap { data, response in
            guard let networkResponse = response as? HTTPURLResponse else {
                throw APIFailure.invalidNetworkResponse
            }
            if let error = NetworkingError.from(httpCode: networkResponse.statusCode) {
                throw error
            } else {
                return data
            }
        }
        .decode(type: DataType.self, decoder: decoder)
        .eraseToAnyPublisher()
    }
}
