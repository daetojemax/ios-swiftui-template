import SwiftUI
import Design
import Client
import Core
import Navigation

public struct AuthorizationScreen: View {
    @Environment(Auth.self) var auth
    @Environment(NetworkClient.self) var client
    @Environment(AppSimpleRouter.self) var router

    public init() {}

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Authorization")
                .font(.sizeTitle1)
                .foregroundStyle(Color.Fill.black)

            Text("Sign in to continue")
                .font(.sizeText)
                .foregroundStyle(Color.Text.grey4)

            PrimaryButton(title: "Sign In (Mock)") {
                // Mock sign in — implement your auth flow here
            }
            .padding(.horizontal, 16)

            Button("Don't have an account? Register") {
                router.navigateTo(.registration)
            }
            .font(.sizeBody)
            .foregroundStyle(Color.Fill.purple)

            Spacer()
        }
        .fill(.all)
        .background(Color.BG.primary)
    }
}
