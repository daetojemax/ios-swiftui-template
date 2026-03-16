import Foundation

public struct Token: Codable, Sendable {

    public let token: String

    enum CodingKeys: String, CodingKey {
        case token
    }
}
