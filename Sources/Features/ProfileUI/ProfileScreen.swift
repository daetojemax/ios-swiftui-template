import SwiftUI
import Client
import Design
import Navigation

public struct ProfileScreen: View {
    @Environment(AppRouter.self) var router
    @Environment(Auth.self) var auth

    public init() {}

    public var body: some View {
        VStack(spacing: 8) {
            Spacer()

            Text("Profile Screen")
                .font(.sizeTitle1)
                .foregroundStyle(Color.Fill.black)

            Text("Your profile content goes here")
                .font(.sizeText)
                .foregroundStyle(Color.Fill.black.opacity(0.55))

            Button("Logout") {
                logout()
            }
            .font(.sizeBody)
            .foregroundStyle(Color.Fill.purple)

            Spacer()
        }
        .fill(.all)
        .background(Color.Fill.white)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.navigateTo(.settings)
                } label: {
                    Image(systemName: "gearshape")
                }
                .foregroundStyle(Color.Fill.purple)
            }
        }
    }
}

// MARK: - Actions

private extension ProfileScreen {
    func logout() {
        Task {
            do {
                try await auth.logout()
            } catch {
                auth.invalidateSession()
            }
        }
    }
}
