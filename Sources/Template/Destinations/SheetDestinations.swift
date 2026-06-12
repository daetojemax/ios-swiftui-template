import SwiftUI
import Navigation
import Client
import Core

struct SheetDestinations: ViewModifier {
    // Sheets are part of the authenticated presentation layer, so they need the shared
    // environment plus authenticated-only values. Passing them explicitly keeps the base
    // `AppEnvironment` generic and avoids storing `CurrentUser` where it can be nil.
    let environment: AppEnvironment
    let router: AppRouter
    let currentUser: CurrentUser

    func body(content: Content) -> some View {
        @Bindable var router = router

        content
            .sheet(item: $router.presentedSheet) { presentedSheet in
                switch presentedSheet {
                case .placeholder:
                    EmptyView()
                        // Re-inject the same values regular authenticated screens receive.
                        // Add new shared services through `withAuthenticatedEnvironmentValues`
                        // instead of repeating `.environment(...)` chains in each destination.
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
    /// Installs sheet destinations for the authenticated app flow.
    ///
    /// Keep the public surface small: shared services come from `AppEnvironment`, while
    /// `router` and `currentUser` are passed separately because only authenticated screens
    /// should receive them.
    func withSheetDestinations(
        _ environment: AppEnvironment,
        router: AppRouter,
        currentUser: CurrentUser
    ) -> some View {
        modifier(
            SheetDestinations(
                environment: environment,
                router: router,
                currentUser: currentUser
            )
        )
    }
}
