import Client
import Core
import Navigation

// MARK: - Environment

extension AppRoot {
    /// Builds the shared environment from the current root-owned service instances.
    ///
    /// `AppRoot` owns these services with `@State`, so every flow receives the same object
    /// instances and can observe the same streams/state. Do not create new services inside
    /// feature screens; add them to `AppEnvironment` here and inject them through the graph.
    func appEnvironment() -> AppEnvironment {
        AppEnvironment(
            client: client,
            auth: auth,
            toastManager: toastManager,
            preferences: preferences,
            pushManager: pushManager,
            deeplinkManager: deeplinkManager
        )
    }
}
