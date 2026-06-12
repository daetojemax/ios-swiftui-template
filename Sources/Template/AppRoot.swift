import AuthorizationUI
import Client
import Core
import Design
import Navigation
import OnboardingUI
import SplashUI
import SwiftUI
import os

let logger: Logger = Logger(subsystem: "com.template.app", category: "Template")

public struct AppRoot: View {
    
    public init() {}

    @Environment(\.openURL) var openURL

    @State var appState: AppState = .loading
    @State var router: AppRouter = .init(initialTab: .main)
    @State var authRouter: AppSimpleRouter = .init()
    @State var auth: Auth = .init()
    @State var client: NetworkClient = .init()
    @State var toastManager: ToastManager = .init()
    @State var pushManager: PushNotificationsManager = .shared
    @State var deeplinkManager: DeeplinkManager = .shared
    @State var preferences: UserPreferences = .shared

    public var body: some View {
        Group {
            switch appState {
            case .loading:
                SplashScreen {
                    if preferences.isFirstStart {
                        auth.clearStoredConfiguration()
                        preferences.isFirstStart = false
                    }

                    if preferences.onboardingCompleted {
                        Task { await auth.refresh() }
                    } else {
                        appState = .onboarding
                    }
                }
            case .onboarding:
                OnboardingScreen {
                    preferences.onboardingCompleted = true
                    Task { await auth.refresh() }
                }
            case let .authenticated(currentUser):
                AppTabView()
                    .withAuthenticatedAppEnvironment(
                        appEnvironment(),
                        router: router,
                        currentUser: currentUser
                    )
            case .unauthenticated:
                NavigationStack(path: $authRouter.path) {
                    AuthorizationScreen()
                        .withAppDestinations()
                        .navigationBarHidden(true)
                }
                .withUnauthenticatedAppEnvironment(
                    appEnvironment(),
                    authRouter: authRouter
                )
            }
        }
        .withAppServiceConfiguration(
            client: client,
            auth: auth,
            pushManager: pushManager
        )
        // Listens for auth state changes and switches the root app flow.
        .task {
            for await configuration in auth.configurationUpdates {
                await refreshEnvironment(with: configuration)
            }
        }
        // Listens for unrecoverable 401 responses and resets the local session.
        .task {
            for await _ in client.authenticationExpiredUpdates {
                auth.invalidateSession()
            }
        }
        // Listens for parsed push notification events and routes them into app handling.
        .task {
            for await event in pushManager.events {
                handlePushEvent(event)
            }
        }
        // Listens for parsed deeplink events and lets AppRoot decide how to open them.
        .task {
            for await event in deeplinkManager.events {
                processDeeplinkEvent(event)
            }
        }
        .preferredColorScheme(.light)
        .overlay(alignment: .top) {
            AppToast()
                .environment(toastManager)
        }
        // Handles custom URL schemes, for example: template://settings or template://event/21
        .onOpenURL { url in
            handleDeepLink(url)
        }
        // Handles Universal Links, for example: https://template.com/settings or https://template.com/event/21
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
            if let url = userActivity.webpageURL {
                handleDeepLink(url)
            }
        }
    }
}

// MARK: - Authentication

private extension AppRoot {
    func refreshEnvironment(with configuration: AuthConfiguration?) async {
        if let configuration = configuration {
            let currentUser = CurrentUser(
                client: client,
                user: configuration.user
            )
            appState = .authenticated(currentUser: currentUser)
        } else {
            appState = .unauthenticated
        }
    }
}

// MARK: - URL Handling

private extension AppRoot {
    func handleDeepLink(_ url: URL) {
        deeplinkManager.open(url: url)
    }
}

// MARK: - Push Notifications

private extension AppRoot {
    func handlePushEvent(_ event: PushEvent) {
        switch event {
        case .deeplink(let deeplink):
            deeplinkManager.open(deeplink: deeplink)
        case .alert:
            //present alert
            break
        }
    }
}

// MARK: - Deeplink Routing

private extension AppRoot {
    func processDeeplinkEvent(_ event: DeeplinkEvent) {
        guard appState.currentUser != nil else {
            return
        }

        switch event {
        case .settings:
            router.selectedTab = .profile
            router.navigateTo(.settings, for: .profile)
        case .event(let id):
            _ = id
            // Handle business entity by id if needed
        case .url(let url):
            if let url = URL(string: url) {
                openURL(url)
            }
        }
    }
}
