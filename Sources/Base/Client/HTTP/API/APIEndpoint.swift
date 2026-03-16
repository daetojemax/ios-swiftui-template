import Core
import Foundation

public enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

public enum APIVersion: String {
    case v1 = "/v1"
    case none = ""
}

public enum ContentType: String {
    case json = "application/json"
    case formUrlEncoded = "application/x-www-form-urlencoded"
}

// MARK: - API Protocol

public protocol APIEndpoint {
    var url: URL { get }
    var path: String { get }
    var version: APIVersion { get }
    var method: HTTPMethod { get }
    var data: Encodable? { get }
    var formData: [String: String]? { get }
    var contentType: ContentType { get }
    var withToken: Bool { get }
    var isAuthorizeRequest: Bool { get }
    var headers: [String: String] { get }
    var query: [URLQueryItem]? { get }
    var request: URLRequest { get throws }
    var useApiPrefix: Bool { get }
}

public extension APIEndpoint {
    var url: URL {
        return URL(string: NetworkConst.currentHostUrl)!
    }

    var version: APIVersion {
        return .v1
    }

    var headers: [String: String] {
        return [:]
    }

    var data: Encodable? {
        return nil
    }

    var formData: [String: String]? {
        return nil
    }

    var contentType: ContentType {
        return .json
    }

    var query: [URLQueryItem]? {
        return nil
    }

    var withToken: Bool {
        return false
    }

    var isAuthorizeRequest: Bool {
        return false
    }

    var useApiPrefix: Bool {
        return true
    }

    var request: URLRequest {
        get throws {
            let pathPrefix = useApiPrefix ? "/api" + version.rawValue : ""
            guard let url = URL(string: pathPrefix + path, relativeTo: url) else {
                throw NetworkError.invalidURL
            }

            guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                throw NetworkError.invalidURL
            }

            urlComponents.queryItems = query

            guard let requestUrl = urlComponents.url else {
                throw NetworkError.invalidURL
            }

            var urlRequest = URLRequest(url: requestUrl,
                                        cachePolicy: .useProtocolCachePolicy,
                                        timeoutInterval: NetworkConst.requestTimeout)
            urlRequest.httpMethod = method.rawValue

            let accessToken = KeychainWrapper.get("access_token")
            if let accessToken, withToken {
                urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }

            urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: "Content-Type")
            urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: "Accept")

            if method == .POST || method == .PUT {
                switch contentType {
                case .json:
                    if let data = data {
                        urlRequest.httpBody = try? JSONEncoder().encode(data)
                    }
                case .formUrlEncoded:
                    if let formData = formData {
                        urlRequest.setValue(ContentType.formUrlEncoded.rawValue, forHTTPHeaderField: "Content-Type")
                        let bodyString = formData.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }.joined(separator: "&")
                        urlRequest.httpBody = bodyString.data(using: .utf8)
                    }
                }
            }

            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }

            return urlRequest
        }
    }
}
