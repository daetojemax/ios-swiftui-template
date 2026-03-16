import SwiftUI

public enum SheetDestination: SheetType, Hashable, Identifiable {
    public var id: Int { self.hashValue }

    case placeholder
}
