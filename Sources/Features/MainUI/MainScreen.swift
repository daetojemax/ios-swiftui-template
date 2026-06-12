import SwiftUI
import Design

public struct MainScreen: View {

    public init() {}

    public var body: some View {
        VStack(spacing: 8) {
            Spacer()

            Text("Main Screen")
                .font(.sizeTitle1)
                .foregroundStyle(Color.Fill.black)

            Text("Your main content goes here")
                .font(.sizeText)
                .foregroundStyle(Color.Fill.black.opacity(0.55))

            Spacer()
        }
        .fill(.all)
        .background(Color.Fill.white)
    }
}
