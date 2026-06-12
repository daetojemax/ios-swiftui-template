import Core
import Foundation
import Models

public actor RefreshManager {

    private var refreshTask: Task<Void, Error>?

    public init() {}

    public func refresh() async throws {
        if let refreshTask {
            return try await refreshTask.value
        }

        let task = Task { () throws -> Void in
            guard let refreshToken = KeychainWrapper.get(AuthStorageKey.refreshToken) else {
                throw NetworkError.failedRefreshToken(reason: "No refresh token")
            }

            let request = try AuthAPI.refreshToken(refreshToken: refreshToken).request

            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = NetworkConst.requestTimeout
            config.timeoutIntervalForResource = NetworkConst.requestTimeout
            let session = URLSession(configuration: config)

            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                let code = (response as? HTTPURLResponse)?.statusCode ?? 0
                throw NetworkError.failedRefreshToken(reason: "Status: \(code)")
            }

            let token = try JSONDecoder().decode(Token.self, from: data)

            guard let accessToken = token.accessToken, !accessToken.isEmpty else {
                throw NetworkError.failedRefreshToken(reason: "Empty access token")
            }
            KeychainWrapper.set(accessToken, for: AuthStorageKey.accessToken)
            if let newRefreshToken = token.refreshToken {
                KeychainWrapper.set(newRefreshToken, for: AuthStorageKey.refreshToken)
            }
        }

        self.refreshTask = task
        defer {
            self.refreshTask = nil
        }
        try await task.value
    }
}
