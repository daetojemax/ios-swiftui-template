import SwiftUI
import Design

public struct RegistrationScreen: View {

    public init() {}

    public var body: some View {
        VStack(spacing: 8) {
            Spacer()

            Text("Registration Screen")
                .font(.sizeTitle1)
                .foregroundStyle(Color.Fill.black)

            Text("Create your account here")
                .font(.sizeText)
                .foregroundStyle(Color.Fill.black.opacity(0.55))

            Spacer()
        }
        .fill(.all)
        .background(Color.Fill.white)
    }
}
