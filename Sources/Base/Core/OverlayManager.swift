import Foundation
import Observation

@Observable
@MainActor
public final class OverlayManager: Sendable {

    private(set) public var currentOverlay: OverlayType?

    public init() {}

    public func show(_ overlay: OverlayType) {
        currentOverlay = overlay
    }

    public func dismiss() {
        currentOverlay = nil
    }

    public var isPresented: Bool {
        currentOverlay != nil
    }
}
