import Foundation
import SwiftUI

public enum AlignmentFill {
    case all
    case vertical
    case horizontal
}

extension View {

    @ViewBuilder
    public func fill(_ fill: AlignmentFill, alignment: Alignment = .center) -> some View {
        switch fill {
        case .all:
            frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
        case .horizontal:
            frame(maxWidth: .infinity, alignment: alignment)
        case .vertical:
            frame(maxHeight: .infinity, alignment: alignment)
        }
    }
}

extension View {
    public func leadingAligned() -> some View {
        self.fill(.horizontal, alignment: .leading)
    }
}
