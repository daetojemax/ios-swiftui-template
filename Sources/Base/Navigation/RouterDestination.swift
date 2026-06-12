import SwiftUI

public enum RouterDestination: DestinationType, Hashable, Sendable {
    case registration
    case settings

    public static func from(path: String, fullPath: [String], parameters: [String: String]) -> RouterDestination? {
        switch path.lowercased() {
        case "registration":
            return .registration
        case "settings":
            return .settings
        default:
            return nil
        }
    }
}
