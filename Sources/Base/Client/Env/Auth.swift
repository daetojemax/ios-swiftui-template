import Foundation
import Core
import Observation
import Models

public struct AuthConfiguration: Sendable {
    public let token: String
    public let user: User

    public init(token: String, user: User) {
        self.token = token
        self.user = user
    }
}

@Observable
public final class Auth: Sendable {
    private let keychainTokenKey = "access_token"
    private let keychainUserKey = "user_data"

    private let configurationContinuation: AsyncStream<AuthConfiguration?>.Continuation?
    public let configurationUpdates: AsyncStream<AuthConfiguration?>

    public init() {
        let (stream, continuation) = AsyncStream<AuthConfiguration?>.makeStream()
        self.configurationUpdates = stream
        self.configurationContinuation = continuation
    }

    public func refresh() async {
        let configuration = await loadStoredConfiguration()
        configurationContinuation?.yield(configuration)
    }

    public func logout(using client: NetworkClient) async {
        let _: Empty? = try? await client.request(AuthAPI.logout)

        KeychainWrapper.delete(keychainTokenKey)
        KeychainWrapper.delete(keychainUserKey)
        configurationContinuation?.yield(nil)
    }

    private func loadStoredConfiguration() async -> AuthConfiguration? {
        guard let token = KeychainWrapper.get(keychainTokenKey),
              let userString = KeychainWrapper.get(keychainUserKey),
              let userData = userString.data(using: String.Encoding.utf8),
              let user = try? JSONDecoder().decode(User.self, from: userData) else {
            return nil
        }

        return AuthConfiguration(
            token: token,
            user: user
        )
    }
}
