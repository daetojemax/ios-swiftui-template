import SwiftUI
import Template

@main struct TemplateApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            AppRoot()
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                break
            case .inactive:
                break
            case .background:
                break
            @unknown default:
                print("unknown app phase: \(newPhase)")
            }
        }
    }
}
