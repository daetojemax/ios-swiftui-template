import Design
import Navigation
import SwiftUI

struct AppTabView: View {
    @Environment(AppRouter.self) var router
    let tabs: [AppTab] = [.main, .profile]

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            ForEach(tabs, id: \.id) { tab in
                AppTabRootView(tab: tab)
                    .tabItem {
                        Label {
                            tab.title
                        } icon: {
                            tab.icon
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 28, height: 28)
                        }
                    }
                    .tag(tab)
                    #if !os(macOS)
                    .toolbarBackground(Color.BG.primary, for: .tabBar)
                    .toolbarBackground(.visible, for: .tabBar)
                    #endif
            }
        }
        .tint(Color.Fill.purple)
    }
}
