import SwiftUI

public struct ErrorToast: View {
    let message: String
    let onDismiss: () -> Void

    public init(message: String, onDismiss: @escaping () -> Void) {
        self.message = message
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(spacing: 16) {
            Text(message)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color.Text.white)
                .multilineTextAlignment(.leading)
                .lineLimit(2)

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.Text.white)
            }
            .buttonStyle(.plain)
        }
        .frame(height: 60)
        .padding(.horizontal, 16)
        .background(Color.Fill.errorToast)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 2)
        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
    }
}
