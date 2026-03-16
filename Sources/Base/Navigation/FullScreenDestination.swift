import SwiftUI
import Foundation

public enum FullScreenDestination: FullScreenType, DestinationType, Hashable, Identifiable {
    public var id: Int { self.hashValue }

    case placeholder

    public static func from(path: String, fullPath: [String], parameters: [String: String]) -> Self? {
        nil
    }
}
