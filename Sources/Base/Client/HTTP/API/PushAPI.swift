import Models

public enum PushAPI {
    case registerDeviceToken(PushDeviceTokenRequest)
}

extension PushAPI: APIEndpoint {
    public var path: String {
        switch self {
        case .registerDeviceToken:
            return "/push/device-token"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .registerDeviceToken:
            return .POST
        }
    }

    public var withToken: Bool {
        switch self {
        case .registerDeviceToken:
            return true
        }
    }

    public var data: Encodable? {
        switch self {
        case .registerDeviceToken(let request):
            return request
        }
    }
}
