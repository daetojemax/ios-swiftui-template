import SwiftUI

public enum SheetDestination: SheetType, Hashable, Identifiable, Sendable {
    public var id: Int { self.hashValue }

    case placeholder

    public static func from(pathComponents: [String], parameters: [String: String]) -> Self? {
        guard let path = pathComponents.first?.lowercased() else { return nil }
        switch path {
        case "placeholder":
            return .placeholder
        default:
            return nil
        }
    }
}
