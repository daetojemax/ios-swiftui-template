import Foundation
import SwiftUI

/// A type that can serve as a navigation destination.
public protocol DestinationType: Hashable {
    static func from(path: String, fullPath: [String], parameters: [String: String]) -> Self?
}

/// A type that can be presented as a sheet.
public protocol SheetType: Hashable, Identifiable {}

/// A type that can be presented as a full screen cover.
public protocol FullScreenType: Hashable, Identifiable {}

/// A type that can serve as a tab in a tab-based navigation system.
public protocol TabType: Hashable, CaseIterable, Identifiable, Sendable {
    var icon: Image { get }
}
