import Client

enum AppState: Sendable {
    case loading
    case onboarding
    case authenticated(currentUser: CurrentUser)
    case unauthenticated
}

extension AppState {
    var currentUser: CurrentUser? {
        switch self {
        case .authenticated(let currentUser):
            return currentUser
        default:
            return nil
        }
    }
}
