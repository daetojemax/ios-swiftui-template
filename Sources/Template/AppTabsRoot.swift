import Design
import MainUI
import Navigation
import ProfileUI
import SwiftUI

private struct CurrentTabKey: EnvironmentKey {
    static let defaultValue: AppTab = .main
}

extension EnvironmentValues {
    var currentTab: AppTab {
        get { self[CurrentTabKey.self] }
        set { self[CurrentTabKey.self] = newValue }
    }
}

struct AppTabRootView: View {
    @Environment(AppRouter.self) var router

    let tab: AppTab

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router[tab]) {
            tab.rootView
                #if !os(macOS)
                .navigationBarHidden(true)
                #endif
                .withAppDestinations()
                .environment(\.currentTab, tab)
        }
        .background(Color.Fill.black)
    }
}

private extension AppTab {
    @MainActor
    @ViewBuilder
    var rootView: some View {
        switch self {
        case .main:
            MainScreen()
        case .profile:
            ProfileScreen()
        }
    }
}
