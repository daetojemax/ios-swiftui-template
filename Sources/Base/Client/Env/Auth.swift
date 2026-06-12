import Foundation
import Core
import Observation
import Models

public struct AuthConfiguration: Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let user: User

    public init(accessToken: String, refreshToken: String, user: User) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.user = user
    }
}

@Observable
@MainActor
public final class Auth: Sendable {

    private var client: NetworkClient?
    private let configurationContinuation: AsyncStream<AuthConfiguration?>.Continuation?
    public let configurationUpdates: AsyncStream<AuthConfiguration?>

    public init() {
        let (stream, continuation) = AsyncStream<AuthConfiguration?>.makeStream()
        self.configurationUpdates = stream
        self.configurationContinuation = continuation
    }
}

// MARK: - Configuration

public extension Auth {
    func configure(client: NetworkClient) {
        self.client = client
    }
}

// MARK: - Session

public extension Auth {
    func refresh() async {
        let configuration = await loadStoredConfiguration()
        configurationContinuation?.yield(configuration)
    }

    func setAuthenticated(accessToken: String, refreshToken: String, user: User) {
        KeychainWrapper.set(accessToken, for: AuthStorageKey.accessToken)
        KeychainWrapper.set(refreshToken, for: AuthStorageKey.refreshToken)
        KeychainWrapper.set("true", for: AuthStorageKey.isAuthenticated)

        if let userData = try? JSONEncoder().encode(user),
           let userString = String(data: userData, encoding: .utf8) {
            KeychainWrapper.set(userString, for: AuthStorageKey.userData)
        }

        configurationContinuation?.yield(
            AuthConfiguration(
                accessToken: accessToken,
                refreshToken: refreshToken,
                user: user
            )
        )
    }

    func logout() async throws {
        if let client {
            let _: Empty = try await client.request(AuthAPI.logout)
        }

        clearStoredConfiguration()
        configurationContinuation?.yield(nil)
    }

    func invalidateSession() {
        clearStoredConfiguration()
        configurationContinuation?.yield(nil)
    }

    func clearStoredConfiguration() {
        KeychainWrapper.delete(AuthStorageKey.accessToken)
        KeychainWrapper.delete(AuthStorageKey.refreshToken)
        KeychainWrapper.delete(AuthStorageKey.userData)
        KeychainWrapper.delete(AuthStorageKey.isAuthenticated)
    }
}

// MARK: - Private

private extension Auth {
    func loadStoredConfiguration() async -> AuthConfiguration? {
        guard let accessToken = KeychainWrapper.get(AuthStorageKey.accessToken),
              let refreshToken = KeychainWrapper.get(AuthStorageKey.refreshToken),
              KeychainWrapper.get(AuthStorageKey.isAuthenticated) == "true",
              let userString = KeychainWrapper.get(AuthStorageKey.userData),
              let userData = userString.data(using: String.Encoding.utf8),
              let user = try? JSONDecoder().decode(User.self, from: userData) else {
            return nil
        }

        return AuthConfiguration(
            accessToken: accessToken,
            refreshToken: refreshToken,
            user: user
        )
    }
}
