import SwiftUI

public struct PrimaryButton: View {
    private let title: String
    private let action: () -> Void
    private let isLoading: Bool

    @Environment(\.isEnabled) var isEnabled

    public init(
        title: String,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.action = action
        self.isLoading = isLoading
    }

    public var body: some View {
        Button(action: { action() }) {
            Group {
                if isLoading {
                    LoadingIndicator(size: .regular,
                                     color: Color.Text.white)
                } else {
                    Text(title)
                        .font(.sizeButton)
                        .foregroundStyle(Color.Text.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(backgroundView)
            .cornerRadius(9999)
        }
    }

    private var backgroundView: some ShapeStyle {
        if isLoading {
            Color.Fill.purple
        } else if !isEnabled {
            Color.Fill.purple.opacity(0.2)
        } else {
            Color.Fill.purple
        }
    }
}
