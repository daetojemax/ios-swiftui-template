import Foundation
import Observation
import Core
@preconcurrency import Pulse

@Observable
public final class NetworkClient: Sendable {

    let session: URLSessionProtocol

    public init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        session = URLSessionProxy(configuration: configuration)
    }

    public func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
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
        case 200 ... 299:
            break
        case 401:
            throw NetworkError.unauthorized
        case 500 ... 599:
            throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")
        default:
            throw NetworkError.httpError(httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    #if DEBUG
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
    #endif
}
