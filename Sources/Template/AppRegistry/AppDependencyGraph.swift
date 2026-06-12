import Client
import Core
import Navigation
import SwiftUI

/// Shared app services that are available in both authenticated and unauthenticated flows.
///
/// Keep this container limited to long-lived services owned by `AppRoot`.
/// Flow-specific values are intentionally not stored here:
/// - `AppRouter` exists only in the authenticated tab flow.
/// - `AppSimpleRouter` exists only in the unauthenticated auth flow.
/// - `CurrentUser` exists only after authentication succeeds.
///
/// Feature screens should not receive or store `AppEnvironment` directly. The container is
/// only a composition helper for `AppRoot`, sheet destinations, and full-screen destinations.
/// Screens should access concrete dependencies with `@Environment(Type.self)`, for example:
///
/// ```
/// @Environment(Auth.self) private var auth
/// @Environment(NetworkClient.self) private var client
/// @Environment(PushNotificationsManager.self) private var pushManager
/// ```
struct AppEnvironment {
    let client: NetworkClient
    let auth: Auth
    let toastManager: ToastManager
    let preferences: UserPreferences
    let pushManager: PushNotificationsManager
    let deeplinkManager: DeeplinkManager
}

extension View {

    /// Applies the full authenticated app environment.
    ///
    /// Use this at the root of the authenticated app shell. It injects shared services,
    /// authenticated-only values, and installs presentation destinations that must receive
    /// the same environment as regular screens.
    func withAuthenticatedAppEnvironment(
        _ environment: AppEnvironment,
        router: AppRouter,
        currentUser: CurrentUser
    ) -> some View {
        withAuthenticatedEnvironmentValues(
            environment,
            router: router,
            currentUser: currentUser
        )
        .withSheetDestinations(
            environment,
            router: router,
            currentUser: currentUser
        )
        .withFullScreenDestinations(
            environment,
            router: router,
            currentUser: currentUser
        )
    }

    /// Injects only environment values needed by authenticated screens.
    ///
    /// This helper is reused by sheets and full-screen covers because SwiftUI presentation
    /// boundaries can make dependency availability easy to miss. When adding a new shared
    /// service to `AppEnvironment`, add it here so regular screens and presented screens stay
    /// consistent.
    func withAuthenticatedEnvironmentValues(
        _ appEnvironment: AppEnvironment,
        router: AppRouter,
        currentUser: CurrentUser
    ) -> some View {
        environment(router)
            .environment(appEnvironment.client)
            .environment(currentUser)
            .environment(appEnvironment.auth)
            .environment(appEnvironment.toastManager)
            .environment(appEnvironment.preferences)
            .environment(appEnvironment.pushManager)
            .environment(appEnvironment.deeplinkManager)
    }

    /// Applies the environment for the unauthenticated auth flow.
    ///
    /// This flow gets the shared services plus `AppSimpleRouter`. It does not receive
    /// `AppRouter` or `CurrentUser`, because those values belong to authenticated navigation.
    func withUnauthenticatedAppEnvironment(
        _ appEnvironment: AppEnvironment,
        authRouter: AppSimpleRouter
    ) -> some View {
        environment(authRouter)
            .environment(appEnvironment.auth)
            .environment(appEnvironment.client)
            .environment(appEnvironment.toastManager)
            .environment(appEnvironment.preferences)
            .environment(appEnvironment.pushManager)
            .environment(appEnvironment.deeplinkManager)
    }

    /// Performs one-time service wiring for root-owned app services.
    ///
    /// Environment injection makes services available to views; this modifier configures
    /// service relationships that must exist before those services are used. Keep setup here
    /// limited to app infrastructure, not feature-specific side effects.
    ///
    /// `PushNotificationsManager.configure(client:)` stores the `NetworkClient` dependency
    /// and starts APNS registration. Backend registration remains explicit through
    /// `registerDeviceTokenOnServer()` because it normally requires an authenticated user.
    func withAppServiceConfiguration(
        client: NetworkClient,
        auth: Auth,
        pushManager: PushNotificationsManager
    ) -> some View {
        task {
            auth.configure(client: client)
            pushManager.configure(client: client)
        }
    }
}
