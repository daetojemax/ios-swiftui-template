# iOS SwiftUI Template

Open-source iOS application template built with SwiftUI, Swift Package Manager, Observation, and async/await.

The project is intentionally generic. It provides reusable app infrastructure, module boundaries, navigation, networking, auth scaffolding, push/deeplink plumbing, design-system basics, and demo screens. Product-specific business logic should be added by apps that adopt this template.

## Requirements

- Xcode 16.3+
- Swift 6.2
- iOS 17.0+

## Build & Run

Open the workspace, not the project file:

```bash
open Project.xcworkspace
```

The Xcode project is located at:

```text
App/TemplateApp.xcodeproj
```

The root workspace resolves the Xcode app target and the Swift Package targets from `Package.swift`.

For package-level compilation:

```bash
swift build
```

## What Is Included

- Modular Swift Package architecture
- SwiftUI app root with loading, onboarding, authenticated, and unauthenticated states
- Tab-based navigation using the generic router from the `Navigation` module
- Separate authenticated and unauthenticated navigation flows
- Sheet and full-screen destination mapping
- Typed networking layer with `APIEndpoint`
- Auth scaffold with Keychain-backed token storage
- Token refresh handling
- Push notification manager with APNS token storage and backend registration example
- Deeplink manager with simple typed event parsing
- Environment-based dependency injection
- Minimal design system with reusable components
- Demo login, registration, onboarding, main, profile, and settings screens
- Pulse debug console tab

## Project Structure

```text
App/
└── TemplateApp.swift                  App entry point from the Xcode target

Sources/
├── Template/                          App orchestration layer
│   ├── AppRoot.swift                  Root state machine and app-level event handling
│   ├── AppRoot+Environment.swift      AppEnvironment creation from root-owned services
│   ├── AppState.swift                 Root app state enum
│   ├── AppTabView.swift               Authenticated tab shell
│   ├── AppTabsRoot.swift              Per-tab NavigationStack roots
│   ├── AppDelegate.swift              APNS callbacks and launch notification forwarding
│   ├── AppRegistry/
│   │   └── AppDependencyGraph.swift   Dependency injection and app service setup
│   └── Destinations/
│       ├── AppDestinations.swift      Push navigation destination mapping
│       ├── SheetDestinations.swift    Sheet mapping
│       └── FullScreenDestinations.swift
│
├── Features/
│   ├── AuthorizationUI/               Demo login and registration screens
│   ├── MainUI/                        Demo main tab
│   ├── ProfileUI/                     Demo profile and settings screens
│   ├── SplashUI/                      Splash/loading screen
│   └── OnboardingUI/                  First-run onboarding screen
│
└── Base/
    ├── Navigation/                    Router typealiases, tabs, destinations, deeplinks
    ├── Design/                        Components, colors, fonts, image accessors
    ├── Client/                        NetworkClient, Auth, CurrentUser, push, API endpoints
    ├── Core/                          Keychain, preferences, toasts, haptics, validation wrappers
    └── Models/                        Domain models, requests, responses
```

## Module Architecture

The repository uses Swift Package targets to keep app infrastructure separated from feature UI.

Base modules:

- `Design`: reusable UI components, color accessors, font/image helpers, and resources.
- `Core`: app utilities such as `KeychainWrapper`, `UserPreferences`, `ToastManager`, haptics, and validation wrappers.
- `Models`: domain models, API requests, and API responses.
- `Navigation`: generic app navigation types, destinations, tabs, and deeplink parsing.
- `Client`: networking, auth, current user, push notifications, API endpoints, and token refresh.

Feature modules:

- `AuthorizationUI`
- `MainUI`
- `ProfileUI`
- `SplashUI`
- `OnboardingUI`

Composition module:

- `Template`: owns app assembly, root flow, dependency injection, destinations, push/deeplink event handling, and tab shell.

Dependency direction is intentionally one-way:

```text
Design / Core / Models
        ↓
Navigation / Client
        ↓
Feature UI modules
        ↓
Template app composition
```

Feature modules should contain screens and feature-local UI only. Shared networking, models, navigation primitives, app services, and reusable design assets should live under `Sources/Base`.

## Root Flow

`AppRoot` owns root-level services with `@State`:

```swift
@State var appState: AppState = .loading
@State var router: AppRouter = .init(initialTab: .main)
@State var authRouter: AppSimpleRouter = .init()
@State var auth: Auth = .init()
@State var client: NetworkClient = .init()
@State var toastManager: ToastManager = .init()
@State var pushManager: PushNotificationsManager = .shared
@State var deeplinkManager: DeeplinkManager = .shared
@State var preferences: UserPreferences = .shared
```

The app flow is driven by `AppState`:

- `.loading`: shows `SplashScreen`
- `.onboarding`: shows `OnboardingScreen`
- `.authenticated(currentUser:)`: shows the tab shell
- `.unauthenticated`: shows the auth flow

Startup flow:

1. `SplashScreen` is shown.
2. On first app start, stored auth configuration is cleared.
3. If onboarding is not completed, `OnboardingScreen` is shown.
4. After onboarding, or on later launches, `auth.refresh()` restores auth state.
5. `Auth.configurationUpdates` switches `AppState` to authenticated or unauthenticated.

## Dependency Injection

Dependency injection is centralized in:

```text
Sources/Template/AppRegistry/AppDependencyGraph.swift
Sources/Template/AppRoot+Environment.swift
```

`AppEnvironment` contains shared services available in both authenticated and unauthenticated flows:

```swift
struct AppEnvironment {
    let client: NetworkClient
    let auth: Auth
    let toastManager: ToastManager
    let preferences: UserPreferences
    let pushManager: PushNotificationsManager
    let deeplinkManager: DeeplinkManager
}
```

Flow-specific values are passed separately:

- `AppRouter`: authenticated tab flow only
- `CurrentUser`: authenticated flow only
- `AppSimpleRouter`: unauthenticated auth flow only

This keeps `AppEnvironment` focused on shared services and prevents optional authenticated-only values from leaking into unauthenticated screens.

Authenticated flow:

```swift
AppTabView()
    .withAuthenticatedAppEnvironment(
        appEnvironment(),
        router: router,
        currentUser: currentUser
    )
```

Unauthenticated flow:

```swift
AuthorizationScreen()
    .withUnauthenticatedAppEnvironment(
        appEnvironment(),
        authRouter: authRouter
    )
```

Feature screens should access concrete services through SwiftUI environment:

```swift
@Environment(Auth.self) private var auth
@Environment(NetworkClient.self) private var client
@Environment(AppRouter.self) private var router
@Environment(PushNotificationsManager.self) private var pushManager
@Environment(DeeplinkManager.self) private var deeplinkManager
```

Feature screens should not receive or store `AppEnvironment` directly. It is a composition helper for app assembly and destination modifiers.

Presented views cross SwiftUI presentation boundaries, so sheets and full-screen covers re-inject the same authenticated environment values through `withAuthenticatedEnvironmentValues(...)`.

## Navigation Architecture

The template uses a generic router:

```swift
Router<AppTab, RouterDestination, SheetDestination, FullScreenDestination>
```

The project-level typealias is:

```swift
public typealias AppRouter = Router<AppTab, RouterDestination, SheetDestination, FullScreenDestination>
```

Authenticated navigation is tab-based:

- `AppTabView` owns `TabView`.
- `AppTabsRoot` creates a `NavigationStack` per tab.
- Each tab has its own navigation path through `router[tab]`.
- `router.selectedTab` controls the active tab.

Main pieces:

- `AppTab`: app tabs
- `RouterDestination`: pushed destinations
- `SheetDestination`: sheets
- `FullScreenDestination`: full-screen covers
- `AppDestinations`: maps pushed destination cases to views
- `SheetDestinations`: maps sheet cases to views
- `FullScreenDestinations`: maps full-screen cases to views

To push a screen:

```swift
@Environment(AppRouter.self) private var router

router.navigateTo(.settings, for: .profile)
```

To add a pushed destination:

1. Add a case to `Sources/Base/Navigation/RouterDestination.swift`.
2. Map the case in `Sources/Template/Destinations/AppDestinations.swift`.
3. Navigate with `router.navigateTo(...)`.

To add a sheet:

1. Add a case to `SheetDestination`.
2. Map it in `SheetDestinations`.
3. Present it through `router.presentedSheet`.

To add a full-screen cover:

1. Add a case to `FullScreenDestination`.
2. Map it in `FullScreenDestinations`.
3. Present it through `router.presentedFullScreen`.

## Networking Architecture

Networking lives in `Sources/Base/Client`.

`NetworkClient` exposes one typed API:

```swift
public func request<T: Codable>(
    _ endpoint: APIEndpoint,
    allowRetry: Bool = true
) async throws -> T
```

Endpoints conform to `APIEndpoint`:

```swift
public protocol APIEndpoint {
    var path: String { get }
    var version: APIVersion { get }
    var method: HTTPMethod { get }
    var data: Encodable? { get }
    var formData: [String: String]? { get }
    var contentType: ContentType { get }
    var withToken: Bool { get }
    var isAuthorizeRequest: Bool { get }
    var headers: [String: String] { get }
    var query: [URLQueryItem]? { get }
    var useApiPrefix: Bool { get }
}
```

Endpoint defaults:

- base URL: `NetworkConst.currentHostUrl`
- API prefix: `/api`
- API version: `.v1`
- content type: JSON
- token injection: controlled by `withToken`

Example endpoint:

```swift
public enum PushAPI {
    case registerDeviceToken(PushDeviceTokenRequest)
}

extension PushAPI: APIEndpoint {
    public var path: String { "/push/device-token" }
    public var method: HTTPMethod { .POST }
    public var withToken: Bool { true }
    public var data: Encodable? { ... }
}
```

Token handling:

- If `withToken == true`, `NetworkClient` injects the stored access token into the `Authorization` header.
- If a request returns `401`, `NetworkClient` asks `RefreshManager` to refresh the token once.
- If refresh fails or the retried request is still unauthorized, `authenticationExpiredUpdates` emits an event.
- `AppRoot` listens to `authenticationExpiredUpdates` and invalidates the session through `auth.invalidateSession()`.

Empty responses are decoded as `Empty`:

```swift
public struct Empty: Codable, Sendable {}
```

## Auth Architecture

Auth lives in:

```text
Sources/Base/Client/Env/Auth.swift
Sources/Base/Client/Auth/
```

`Auth` owns the auth lifecycle:

- login/demo authentication
- refresh
- logout
- session invalidation
- persisted auth configuration
- auth state updates

Auth state changes are exposed through:

```swift
Auth.configurationUpdates
```

`AppRoot` listens to that stream:

```swift
for await configuration in auth.configurationUpdates {
    await refreshEnvironment(with: configuration)
}
```

When a valid configuration exists, `AppRoot` creates `CurrentUser` and switches to:

```swift
.authenticated(currentUser: currentUser)
```

When configuration is missing, expired, or invalidated, the app switches to:

```swift
.unauthenticated
```

Credentials and serialized user data are stored through `KeychainWrapper`.

## Push Notifications

Push infrastructure lives in:

```text
Sources/Base/Client/Env/PushNotificationsManager.swift
Sources/Base/Client/Push/PushModels.swift
Sources/Base/Client/HTTP/API/PushAPI.swift
Sources/Base/Models/Requests/PushDeviceTokenRequest.swift
```

`PushNotificationsManager` is responsible for:

- requesting notification permission
- registering for APNS
- storing the raw APNS token
- converting the raw token to a hex string
- registering the APNS token on the backend
- parsing incoming notification payloads into `PushEvent`
- exposing push events through `AsyncStream`

Setup happens from app composition:

```swift
pushManager.configure(client: client)
```

`configure(client:)` stores the `NetworkClient` dependency and starts APNS registration.

Backend token registration is explicit:

```swift
try await pushManager.registerDeviceTokenOnServer()
```

It is not called automatically from `setDeviceToken(_:)` because APNS can return a token before the app has restored an authenticated user. In a real app, call it after authentication or from a push settings screen.

Demo backend endpoint:

```http
POST /api/v1/push/device-token
```

Request body:

```json
{
  "token": "apns-token",
  "platform": "ios"
}
```

Incoming push payloads are parsed by `PushPayloadParser`.

Supported demo payloads:

```json
{ "deeplink": "/settings" }
```

```json
{
  "alert": {
    "title": "Template update",
    "body": "New demo content is available."
  }
}
```

Current push events:

```swift
public enum PushEvent: Sendable {
    case deeplink(String)
    case alert(title: String, body: String)
}
```

These cases are examples. Apps should replace or extend them with product-specific payload actions.

Any screen can subscribe to push events because `PushNotificationsManager` is injected into the environment:

```swift
@Environment(PushNotificationsManager.self) private var pushManager
```

`AppRoot` also listens to push events and routes `.deeplink` into `DeeplinkManager`.

## Deeplinks

Deeplink infrastructure lives in:

```text
Sources/Base/Navigation/DeeplinkManager.swift
```

The deeplink layer is intentionally small. It parses incoming URLs or internal paths into business-level events. It does not decide how to navigate.

Current events:

```swift
public enum DeeplinkEvent: Sendable {
    case settings
    case event(id: String)
    case url(String)
}
```

Supported custom URL examples:

```text
template://settings
template://event/21
```

Supported internal path examples:

```text
/settings
/event/21
```

Parsing rules:

- `/settings` becomes `.settings`
- `/event/21` becomes `.event(id: "21")`
- unknown HTTP/HTTPS URLs become `.url(String)`
- deeplinks are intended for authenticated users only
- unauthenticated deeplink events are ignored by `AppRoot`
- events are not queued for later replay

`DeeplinkManager` emits events through:

```swift
DeeplinkManager.events
```

`AppRoot` listens to that stream and decides what to do:

```swift
case .settings:
    router.selectedTab = .profile
    router.navigateTo(.settings, for: .profile)
case .event(let id):
    // Handle business entity by id if needed
case .url(let url):
    openURL(url)
```

Any screen can also access the manager:

```swift
@Environment(DeeplinkManager.self) private var deeplinkManager
```

## Design System

Design infrastructure lives in:

```text
Sources/Base/Design
```

The template keeps the demo palette intentionally small:

- `black`
- `white`
- `purple`

Typed accessors:

```swift
Color.Fill.black
Color.Fill.white
Color.Fill.purple
```

Use opacity variants for simple demo secondary states:

```swift
Color.Fill.black.opacity(0.55)
Color.Fill.black.opacity(0.05)
```

The goal is to avoid shipping a large set of product-specific colors in a generic template. Apps that adopt the template should replace or extend the palette with their own design system.

Reusable components include:

- `PrimaryButton`
- `HeaderView`
- `SegmentedPicker`
- `ToastView`

Demo screens intentionally avoid custom headers where native navigation is enough. `HeaderView` remains available for apps that need custom navigation/header UI.

## Validation

Validation wrappers live in `Core` and are used by the auth demo form.

Examples:

- required value validation
- email validation

Auth screens use these wrappers to demonstrate how feature UI can keep validation close to form state without adding business-specific logic to the template.

## Toasts

`ToastManager` lives in `Core` and is injected through the environment.

`AppRoot` renders a top-level `AppToast` overlay:

```swift
AppToast()
    .environment(toastManager)
```

Sheet and full-screen destination wrappers also add toast overlays so messages remain visible over presented content.

## User Preferences

`UserPreferences` lives in `Core`.

It stores generic app preferences such as:

- first start flag
- onboarding completion flag

It is injected into both authenticated and unauthenticated flows.

## Demo Screens

The included screens are examples only:

- splash
- onboarding
- login
- registration
- main tab
- profile tab
- settings
- debug console

The login flow is intentionally scaffolded for template usage. Replace demo auth behavior with your backend integration when adopting the template.

## Adding a Feature Module

1. Create a directory:

```text
Sources/Features/YourFeatureUI/
```

2. Add a library product to `Package.swift`.

3. Add a target to `Package.swift`.

Typical dependencies for a UI feature:

```swift
"Design",
"Core",
"Client",
"Navigation"
```

4. Add the feature target as a dependency of `Template`.

5. Add routes if the feature needs navigation:

- pushed route: `RouterDestination`
- sheet: `SheetDestination`
- full-screen cover: `FullScreenDestination`

6. Map the destination in:

```text
Sources/Template/Destinations/
```

7. Navigate from feature UI through environment:

```swift
@Environment(AppRouter.self) private var router
```

## Adding an API Endpoint

1. Add request/response models under `Sources/Base/Models`.

2. Add an API enum under:

```text
Sources/Base/Client/HTTP/API/
```

3. Conform it to `APIEndpoint`.

4. Call it through `NetworkClient`:

```swift
let response: SomeResponse = try await client.request(SomeAPI.someEndpoint)
```

Use `withToken = true` for authenticated endpoints.

## Adding a Push Event

1. Add a new case to `PushEvent`.

2. Update `PushPayloadParser.event(from:)`.

3. Handle the case where it belongs:

- in `AppRoot` for app-level routing or global behavior
- in a feature screen if the screen subscribes to `pushManager.events`

Keep push events concrete. Avoid raw dictionary or generic string payload cases in the template.

## Adding a Deeplink Event

1. Add a new case to `DeeplinkEvent`.

2. Update `DeeplinkManager` parsing.

3. Handle the event in `AppRoot.processDeeplinkEvent(_:)`.

Deeplink events should represent business entities or actions, not navigation instructions. For example:

```swift
case event(id: String)
```

is preferable to:

```swift
case openEventScreen(id: String)
```

`AppRoot` decides how the event is opened.

## Template Guidelines

This repository is intended to stay generic.

Keep in the template:

- reusable app infrastructure
- generic navigation primitives
- typed networking
- auth scaffolding
- push/deeplink examples
- basic UI components
- demo screens

Avoid adding:

- product-specific workflows
- business-specific push actions
- business-specific deeplink routes
- large product color palettes
- one-off UI assets
- backend-specific assumptions beyond examples

## License

MIT
