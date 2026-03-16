import SwiftUI
import Navigation
import AuthorizationUI
import ProfileUI

public struct AppDestinations: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .navigationDestination(for: RouterDestination.self) { destination in
                switch destination {
                case .registration:
                    RegistrationScreen()
                case .settings:
                    SettingsScreen()
                }
            }
    }
}

extension View {
    func withAppDestinations() -> some View {
        modifier(AppDestinations())
    }
}
