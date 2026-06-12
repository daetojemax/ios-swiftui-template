import Models

public enum AuthAPI {
    case login
    case getUser
    case refreshToken(refreshToken: String)
    case logout
}

extension AuthAPI: APIEndpoint {
    public var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .getUser:
            return "/user"
        case .refreshToken:
            return "/auth/token/refresh"
        case .logout:
            return "/auth/logout"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .login, .logout:
            return .POST
        case .refreshToken:
            return .PUT
        case .getUser:
            return .GET
        }
    }

    public var withToken: Bool {
        switch self {
        case .getUser, .logout:
            return true
        case .login, .refreshToken:
            return false
        }
    }

    public var data: Encodable? {
        switch self {
        case .refreshToken(let refreshToken):
            return ["refresh_token": refreshToken]
        default:
            return nil
        }
    }

    public var isAuthorizeRequest: Bool {
        switch self {
        case .login, .refreshToken:
            return true
        default:
            return false
        }
    }
}
