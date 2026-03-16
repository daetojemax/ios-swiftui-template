import SwiftUI

public struct LoadingIndicator: View {

    private let size: ControlSize
    private let color: Color

    public init(size: ControlSize = .large,
                color: Color = .white) {
        self.size = size
        self.color = color
    }

    public var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: color))
            .controlSize(size)
    }
}
