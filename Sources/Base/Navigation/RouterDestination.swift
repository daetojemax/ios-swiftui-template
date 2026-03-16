import SwiftUI

public enum RouterDestination: DestinationType, Hashable {
    case registration
    case settings

    public static func from(path: String, fullPath: [String], parameters: [String: String]) -> RouterDestination? {
        nil
    }
}
