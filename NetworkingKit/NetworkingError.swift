import Foundation

enum NetworkingError: Error {
    case invalidURL
    case noResponse
    case invalidCredentials
    case clientError
    case serverError
    case unknown
    
    static func from(httpCode: Int) -> NetworkingError? {
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
