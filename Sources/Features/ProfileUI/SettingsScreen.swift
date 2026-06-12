import SwiftUI
import Design

public struct SettingsScreen: View {

    public init() {}

    public var body: some View {
        VStack(spacing: 8) {
            Spacer()

            Text("Settings Screen")
                .font(.sizeTitle1)
                .foregroundStyle(Color.Fill.black)

            Text("App settings go here")
                .font(.sizeText)
                .foregroundStyle(Color.Fill.black.opacity(0.55))

            Spacer()
        }
        .fill(.all)
        .background(Color.Fill.white)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
