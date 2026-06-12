import Design
import SwiftUI

public struct SplashScreen: View {

    let onFinish: () -> Void

    @State private var isVisible = false

    public init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    public var body: some View {
        ZStack {
            Color.Fill.purple
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Template")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(Color.Fill.white)
                    .opacity(isVisible ? 1 : 0)
                    .scaleEffect(isVisible ? 1 : 0.92)
            }
        }
        .task {
            await animate()
        }
    }

    @MainActor
    private func animate() async {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
            isVisible = true
        }

        do {
            try await Task.sleep(for: .milliseconds(900))
        } catch {
            return
        }

        guard !Task.isCancelled else { return }
        onFinish()
    }
}
