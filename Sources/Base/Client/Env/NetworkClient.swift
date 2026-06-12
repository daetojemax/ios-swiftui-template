import Foundation
import Observation
import Core
@preconcurrency import Pulse

@Observable
public final class NetworkClient: Sendable {
    
    let session: URLSessionProtocol
    private let refreshManager: RefreshManager = .init()
    private let authenticationExpiredContinuation: AsyncStream<Void>.Continuation?
    public let authenticationExpiredUpdates: AsyncStream<Void>
    
    public init() {
        let (stream, continuation) = AsyncStream<Void>.makeStream()
        self.authenticationExpiredUpdates = stream
        self.authenticationExpiredContinuation = continuation
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = NetworkConst.requestTimeout
        configuration.timeoutIntervalForResource = NetworkConst.requestTimeout
        session = URLSessionProxy(configuration: configuration)
    }
    
    public func request<T: Codable>(_ endpoint: APIEndpoint, allowRetry: Bool = true) async throws -> T {
        do {
            return try await performRequest(endpoint)
        } catch NetworkError.unauthorized where !endpoint.isAuthorizeRequest {
            if allowRetry {
                do {
                    try await refreshManager.refresh()
                } catch {
                    await expireAuthentication()
                    throw error
                }
                return try await request(endpoint, allowRetry: false)
            }
            await expireAuthentication()
            throw NetworkError.failedRefreshToken(reason: "401 after refresh")
        }
    }
    
}

// MARK: - Request

private extension NetworkClient {
    func performRequest<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        let request = try endpoint.request
        
#if DEBUG
        printRequest(request)
#endif
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
#if DEBUG
        printResponse(statusCode: httpResponse.statusCode, data: data, url: request.url)
#endif
        
        switch httpResponse.statusCode {
        case 201:
            throw NetworkError.pending
        case 200, 202 ... 299:
            break
        case 401:
            throw NetworkError.unauthorized
        case 500 ... 599:
            throw makeHTTPError(statusCode: httpResponse.statusCode, data: data)
        default:
            throw makeHTTPError(statusCode: httpResponse.statusCode, data: data)
        }
        
        do {
            let decoder = JSONDecoder()
            let jsonData = data.isEmpty ? "{}".data(using: .utf8)! : data
            return try decoder.decode(T.self, from: jsonData)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    func expireAuthentication() async {
        authenticationExpiredContinuation?.yield(())
    }
    
    func makeHTTPError(statusCode: Int, data: Data) -> NetworkError {
        if let message = decodeErrorMessage(from: data) {
            return .serverError(message)
        }
        
        if (500 ... 599).contains(statusCode) {
            return .serverError("Server error")
        }
        
        return .httpError(statusCode)
    }
    
    func decodeErrorMessage(from data: Data) -> String? {
        guard !data.isEmpty,
              let response = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) else {
            return nil
        }
        
        let message = response.message.trimmingCharacters(in: .whitespacesAndNewlines)
        return message.isEmpty ? nil : message
    }
}

// MARK: - Debug

#if DEBUG
private extension NetworkClient {
    private func printRequest(_ request: URLRequest) {
        let method = request.httpMethod ?? "GET"
        let urlString = request.url?.absoluteString ?? "Unknown URL"
        print("\n┌─────────── REQUEST ───────────")
        print("│ ➡️ \(method) \(urlString)")
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            for (key, value) in headers {
                print("│ 📋 \(key): \(value)")
            }
        }
        if let body = request.httpBody,
           let json = try? JSONSerialization.jsonObject(with: body),
           let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("│ 📝 Body:")
            for line in prettyString.components(separatedBy: "\n") {
                print("│   \(line)")
            }
        } else if let body = request.httpBody, let rawString = String(data: body, encoding: .utf8) {
            print("│ 📝 Body: \(rawString)")
        }
        print("└──────────────────────────────")
    }
    
    private func printResponse(statusCode: Int, data: Data, url: URL?) {
        let urlString = url?.absoluteString ?? "Unknown URL"
        print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📡 \(urlString)")
        print("📊 Status: \(statusCode)")
        
        if let json = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("📦 Response:")
            print(prettyString)
        } else if let rawString = String(data: data, encoding: .utf8) {
            print("📦 Response (raw):")
            print(rawString)
        } else {
            print("📦 Response: Unable to decode")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    }
}
#endif

private struct ServerErrorResponse: Decodable {
    let message: String
}
