import Core
import Design
import SwiftUI

public struct AppToast: View {

    @Environment(ToastManager.self) var toastManager

    public init() {}

    public var body: some View {
        VStack {
            if let toast = toastManager.currentToast {
                ToastView(
                    message: toast.message,
                    kind: toast.type.toastViewKind,
                    onDismiss: { toastManager.dismiss() }
                )
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            Spacer()
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: toastManager.isPresented)
    }
}

private extension ToastType {
    var toastViewKind: ToastView.Kind {
        switch self {
        case .error:
            .error
        case .success:
            .success
        }
    }
}
