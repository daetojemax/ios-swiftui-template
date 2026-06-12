import SwiftUI

public struct ToastView: View {
    public enum Kind {
        case error
        case success
    }

    let message: String
    let kind: Kind
    let onDismiss: () -> Void

    public init(message: String, kind: Kind, onDismiss: @escaping () -> Void) {
        self.message = message
        self.kind = kind
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 16) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.Fill.white)
            }

            Text(message)
                .font(.sizeBody)
                .foregroundColor(Color.Fill.white)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.Fill.white)
            }
            .buttonStyle(.plain)
            .padding(.top, 3)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .frame(minHeight: 60)
        .background(backgroundColor)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 2)
        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
    }

    private var icon: String? {
        switch kind {
        case .error:
            nil
        case .success:
            "checkmark.circle.fill"
        }
    }

    private var backgroundColor: Color {
        switch kind {
        case .error:
            Color.Fill.purple
        case .success:
            Color.Fill.black
        }
    }
}
