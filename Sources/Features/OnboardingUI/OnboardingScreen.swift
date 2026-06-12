import Design
import SwiftUI

public struct OnboardingScreen: View {

    let onFinish: () -> Void

    public init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(Color.Fill.purple)

                Text("Onboarding")
                    .font(.sizeTitle1)
                    .foregroundStyle(Color.Fill.black)

                Text("Demo onboarding screen. Replace this content with your product flow.")
                    .font(.sizeText)
                    .foregroundStyle(Color.Fill.black.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            PrimaryButton(title: "Continue") {
                onFinish()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .fill(.all)
        .background(Color.Fill.white)
    }
}
