import Foundation

public enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case httpError(Int)
    case unauthorized
    case serverError(String)
    case failedRefreshToken(reason: String)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .httpError(let statusCode):
            return "HTTP Error: \(statusCode)"
        case .unauthorized:
            return "Unauthorized"
        case .serverError(let message):
            return "Server error: \(message)"
        case .failedRefreshToken(let reason):
            return "Failed to refresh token: \(reason)"
        }
    }
}
