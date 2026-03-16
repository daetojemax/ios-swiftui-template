import Client

enum AppState: Sendable {
    case loading
    case authenticated(client: NetworkClient, currentUser: CurrentUser)
    case unauthenticated(client: NetworkClient)
}

extension AppState {
    var client: NetworkClient? {
        switch self {
        case .authenticated(let client, _):
            return client
        case .unauthenticated(let client):
            return client
        default:
            return nil
        }
    }

    var currentUser: CurrentUser? {
        switch self {
        case .authenticated(_, let currentUser):
            return currentUser
        default:
            return nil
        }
    }
}
