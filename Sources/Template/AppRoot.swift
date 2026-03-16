import AuthorizationUI
import Client
import Core
import Design
import Navigation
import SwiftUI
import os

let logger: Logger = Logger(subsystem: "com.template.app", category: "Template")

public struct AppRoot: View {
    public init() {}
    @State var appState: AppState = .loading
    @State var router: AppRouter = .init(initialTab: .main)
    @State var authRouter: AppSimpleRouter = .init()
    @State var auth: Auth = .init()
    @State var errorManager: ErrorManager = .init()

    public var body: some View {
        @Bindable var authRouter = authRouter

        Group {
            switch appState {
            case .loading:
                ProgressView()
                    .fill(.all)
                    .background(Color.BG.primary)
                    .task {
                        await auth.refresh()
                    }
            case let .authenticated(client, currentUser):
                AppTabView()
                    .environment(router)
                    .environment(client)
                    .environment(currentUser)
                    .environment(auth)
                    .environment(errorManager)
            case let .unauthenticated(client):
                NavigationStack(path: $authRouter.path) {
                    AuthorizationScreen()
                        .withAppDestinations()
                        #if !os(macOS)
                        .navigationBarHidden(true)
                        #endif
                }
                .environment(authRouter)
                .environment(auth)
                .environment(client)
                .environment(errorManager)
            }
        }
        .task {
            for await configuration in auth.configurationUpdates {
                await refreshEnvironment(with: configuration)
            }
        }
        .preferredColorScheme(.light)
        .overlay(alignment: .top) {
            AppError()
                .environment(errorManager)
        }
    }

    private func refreshEnvironment(with configuration: AuthConfiguration?) async {
        let client = NetworkClient()

        if let configuration = configuration {
            let currentUser = CurrentUser(
                client: client,
                user: configuration.user
            )
            appState = .authenticated(client: client, currentUser: currentUser)
        } else {
            appState = .unauthenticated(client: client)
        }
    }
}
