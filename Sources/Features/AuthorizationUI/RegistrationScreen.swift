import SwiftUI
import Design

public struct RegistrationScreen: View {

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "Registration", type: .navigation)

            Spacer()

            Text("Registration Screen")
                .font(.sizeTitle1)
                .foregroundStyle(Color.Fill.black)

            Text("Create your account here")
                .font(.sizeText)
                .foregroundStyle(Color.Text.grey4)
                .padding(.top, 8)

            Spacer()
        }
        .fill(.all)
        .background(Color.BG.primary)
    }
}
