import SwiftUI
import Design

public struct SettingsScreen: View {

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "Settings", type: .navigation)

            Spacer()

            Text("Settings Screen")
                .font(.sizeTitle1)
                .foregroundStyle(Color.Fill.black)

            Text("App settings go here")
                .font(.sizeText)
                .foregroundStyle(Color.Text.grey4)
                .padding(.top, 8)

            Spacer()
        }
        .fill(.all)
        .background(Color.BG.primary)
    }
}
