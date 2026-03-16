import SwiftUI

public enum ButtonPosition {
    case leading
    case trailing
}

public enum HeaderType {
    case navigation
    case modal
    case titleOnly
    case custom(systemImage: String, position: ButtonPosition = .leading, action: () -> Void)
    case transparent
}

public struct HeaderView: View {
    @Environment(\.dismiss) var dismiss
    let title: String
    let type: HeaderType

    public init(
        title: String = "",
        type: HeaderType = .navigation
    ) {
        self.title = title
        self.type = type
    }

    public var body: some View {
        if case .transparent = type {
            transparentHeader
        } else {
            standardHeader
        }
    }

    private var standardHeader: some View {
        HStack(spacing: 0) {
            Group {
                switch type {
                case .navigation:
                    actionButton
                case let .custom(_, position, _) where position == .leading:
                    actionButton
                default:
                    Color.clear.frame(width: 48, height: 48)
                }
            }

            Spacer()

            if !title.isEmpty {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.Fill.black)
                    .lineLimit(1)
            }

            Spacer()

            Group {
                switch type {
                case .modal:
                    actionButton
                case let .custom(_, position, _) where position == .trailing:
                    actionButton
                case .navigation, .titleOnly, .custom, .transparent:
                    Color.clear.frame(width: 48, height: 48)
                }
            }
        }
        .frame(height: 48)
    }

    private var transparentHeader: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                        .frame(width: 48, height: 48)

                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.Text.white)
                }
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .frame(height: 48)
    }

    @ViewBuilder
    private var actionButton: some View {
        switch type {
        case .navigation:
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.Fill.black)
                    .frame(width: 48, height: 48)
            }
            .buttonStyle(.plain)

        case .modal:
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.Fill.black)
                    .frame(width: 48, height: 48)
            }
            .buttonStyle(.plain)

        case let .custom(systemImage, _, action):
            Button {
                action()
            } label: {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.Fill.black)
                    .frame(width: 48, height: 48)
            }
            .buttonStyle(.plain)

        case .titleOnly, .transparent:
            EmptyView()
        }
    }
}
