import SwiftUI
import Foundation

public enum FullScreenDestination: FullScreenType, DestinationType, Hashable, Identifiable, Sendable {
    public var id: Int { self.hashValue }

    case placeholder

    public static func from(path: String, fullPath: [String], parameters: [String: String]) -> Self? {
        switch path.lowercased() {
        case "placeholder":
            return .placeholder
        default:
            return nil
        }
    }

    public static func from(pathComponents: [String], parameters: [String: String]) -> Self? {
        guard let path = pathComponents.first else { return nil }
        return from(path: path, fullPath: pathComponents, parameters: parameters)
    }
}
