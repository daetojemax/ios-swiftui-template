import SwiftUI
import Design

public struct MainScreen: View {

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "Main", type: .titleOnly)

            Spacer()

            Text("Main Screen")
                .font(.sizeTitle1)
                .foregroundStyle(Color.Fill.black)

            Text("Your main content goes here")
                .font(.sizeText)
                .foregroundStyle(Color.Text.grey4)
                .padding(.top, 8)

            Spacer()
        }
        .fill(.all)
        .background(Color.BG.primary)
    }
}
