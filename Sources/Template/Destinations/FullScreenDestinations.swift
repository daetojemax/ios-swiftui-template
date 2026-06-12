import SwiftUI
import Navigation
import Client
import Core

struct FullScreenDestinations: ViewModifier {
    // Full-screen covers follow the same dependency rules as sheets: shared services come
    // from `AppEnvironment`, while authenticated-only values stay explicit.
    let environment: AppEnvironment
    let router: AppRouter
    let currentUser: CurrentUser

    func body(content: Content) -> some View {
        @Bindable var router = router

        content
            .fullScreenCover(item: $router.presentedFullScreen) { presentedFullScreen in
                switch presentedFullScreen {
                case .placeholder:
                    EmptyView()
                        // Re-inject the authenticated environment across the presentation
                        // boundary so full-screen views can use the same `@Environment`
                        // dependencies as normal pushed screens.
                        .withAuthenticatedEnvironmentValues(
                            environment,
                            router: router,
                            currentUser: currentUser
                        )
                        .overlay(alignment: .top) {
                            AppToast()
                                .environment(environment.toastManager)
                        }
                }
            }
    }
}

extension View {
    /// Installs full-screen destinations for the authenticated app flow.
    func withFullScreenDestinations(
        _ environment: AppEnvironment,
        router: AppRouter,
        currentUser: CurrentUser
    ) -> some View {
        modifier(
            FullScreenDestinations(
                environment: environment,
                router: router,
                currentUser: currentUser
            )
        )
    }
}
