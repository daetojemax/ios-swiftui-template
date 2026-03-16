import SwiftUI
import Core
import Design

public struct AppError: View {

    @Environment(ErrorManager.self) var errorManager

    public init() {}

    public var body: some View {
        VStack {
            if let message = errorManager.currentError {
                ErrorToast(
                    message: message,
                    onDismiss: { errorManager.dismiss() }
                )
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            Spacer()
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: errorManager.isPresented)
    }
}
