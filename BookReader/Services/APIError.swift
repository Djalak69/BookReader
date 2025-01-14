import Foundation

enum APIError: Error {
    case serverError(String)
    case networkError(Error)
    
    var message: String {
        switch self {
        case .serverError(let message):
            return message
        case .networkError(let error):
            return error.localizedDescription
        }
    }
} 