import SwiftUI
import Design
import Navigation

public struct ProfileScreen: View {
    @Environment(AppRouter.self) var router

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                title: "Profile",
                type: .custom(systemImage: "gearshape", position: .trailing) {
                    router.navigateTo(.settings)
                }
            )

            Spacer()

            Text("Profile Screen")
                .font(.sizeTitle1)
                .foregroundStyle(Color.Fill.black)

            Text("Your profile content goes here")
                .font(.sizeText)
                .foregroundStyle(Color.Text.grey4)
                .padding(.top, 8)

            Spacer()
        }
        .fill(.all)
        .background(Color.BG.primary)
    }
}
