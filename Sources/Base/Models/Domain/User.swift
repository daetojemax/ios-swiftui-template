public struct User: Codable, Sendable {
    public let id: Int
    public let email: String?
    public let phone: String?
    public let firstName: String?
    public let lastName: String?

    public init(
        id: Int,
        email: String? = nil,
        phone: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil
    ) {
        self.id = id
        self.email = email
        self.phone = phone
        self.firstName = firstName
        self.lastName = lastName
    }

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case phone
        case firstName = "first_name"
        case lastName = "last_name"
    }
}
