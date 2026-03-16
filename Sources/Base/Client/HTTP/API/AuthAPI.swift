import Models

public enum AuthAPI {
    case login
    case getUser
    case logout
}

extension AuthAPI: APIEndpoint {
    public var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .getUser:
            return "/user"
        case .logout:
            return "/auth/logout"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .login, .logout:
            return .POST
        case .getUser:
            return .GET
        }
    }

    public var withToken: Bool {
        switch self {
        case .getUser, .logout:
            return true
        default:
            return false
        }
    }

    public var isAuthorizeRequest: Bool {
        switch self {
        case .login:
            return true
        default:
            return false
        }
    }
}
