import Foundation

enum ErrorCatch: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid request URL."
        case .invalidResponse:
            return "Invalid server response."
        case .httpError(let statusCode):
            switch statusCode {
            case 400:
                return "Bad request. Please try again."
            case 401:
                return "Unauthorized request."
            case 403:
                return "Access denied."
            case 404:
                return "Weather data not found."
            case 500...599:
                return "Server error. Please try later."
            default:
                return "Request failed with status code \(statusCode)."
            }
        case .decodingError:
            return "Failed to process weather data."
        case .noData:
            return "No data received from server."
        }
    }
}
