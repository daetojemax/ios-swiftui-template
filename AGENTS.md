# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Project Overview

iOS SwiftUI app template with a modular Swift Package architecture. Pure iOS, no cross-platform layer. Swift tools 6.2, iOS 17.0+, SwiftUI, Observation, async/await.

The package is named `Template`. The Xcode app target is named `template`, produces `template.app`, and uses bundle identifier `plus.studio.template`.

This is an open-source starter template. Keep infrastructure generic and keep business logic out of the base project. Demo screens and placeholder routes are acceptable; product-specific workflows belong in apps that adopt the template.

## Build & Run

```bash
# SPM build on the macOS host; verifies package compilation
swift build

# iOS build/run; always open the workspace, not the project directly
open Project.xcworkspace
```

The Xcode project lives at `App/TemplateApp.xcodeproj`. The root workspace `Project.xcworkspace` references that project and resolves `Package.swift`. Do not open the xcodeproj directly for normal development.

## Architecture

**11 SPM dynamic library products + 1 Xcode app target:**

```
App/TemplateApp.swift                  @main entry point (Xcode target)
    └── Template                       App orchestration
        ├── AppRoot                    Root state machine, dependency injection, links/push handling
        ├── AppTabView/AppTabsRoot     Authenticated tab shell
        ├── Destinations/              Navigation, sheet, full-screen mappings
        ├── Features/
        │   ├── AuthorizationUI        Authorization and registration screens
        │   ├── MainUI                 Main tab screen
        │   ├── ProfileUI              Profile and settings screens
        │   ├── SplashUI               Splash/loading screen
        │   └── OnboardingUI           First-run onboarding screen
        └── Base/
            ├── Navigation             Router, SimpleRouter, tabs, destinations, deeplinks
            ├── Design                 Components, colors, fonts, image accessors
            ├── Client                 NetworkClient, Auth, CurrentUser, push, API endpoints
            ├── Core                   KeychainWrapper, UserPreferences, ToastManager, Haptic, validation wrappers
            └── Models                 Domain models plus API request/response types
```

**Dependency graph:** `Design` and `Models` are standalone. `Core` depends on `KeychainSwift`. `Navigation` depends on `Design` and `Models`. `Client` depends on `Models`, `Core`, and `Pulse`. `AuthorizationUI`, `MainUI`, and `ProfileUI` depend on `Design`, `Core`, `Client`, and `Navigation`. `SplashUI` and `OnboardingUI` depend only on `Design`. `Template` depends on all local modules plus `PulseUI`.

External packages are declared in `Package.swift`:

- `keychain-swift` for secure token/user storage.
- `Pulse`/`PulseUI` for network logging and the debug console tab.

## Root Flow & State

`AppRoot` owns the app-level state and long-lived services via `@State`:

- `AppState`: `.loading`, `.onboarding`, `.authenticated(currentUser:)`, `.unauthenticated`
- `AppRouter` for authenticated tab navigation
- `AppSimpleRouter` for the unauthenticated auth stack
- `Auth`, `NetworkClient`, `ToastManager`, `PushNotificationsManager`, `DeeplinkManager`, `UserPreferences`

Startup flow:

1. Show `SplashScreen`.
2. On first app start, clear stored auth configuration and set `isFirstStart = false`.
3. If onboarding is not completed, show `OnboardingScreen`.
4. After onboarding or on later launches, call `auth.refresh()`.
5. `Auth.configurationUpdates` drives `.authenticated` or `.unauthenticated`.

State properties used by SwiftUI/Observation should remain at least `internal`; do not make them `private` when bindings, environment injection, previews, or observation need access.

## Navigation

Generic `Router<Tab, Destination, Sheet, FullScreen>` manages per-tab `NavigationStack` paths, sheets, and full-screen covers.

- `AppRouter` is `Router<AppTab, RouterDestination, SheetDestination, FullScreenDestination>`.
- `AppSimpleRouter` is `SimpleRouter<RouterDestination, SheetDestination, FullScreenDestination>`.
- Auth flow uses `AppSimpleRouter` in its own `NavigationStack` in `AppRoot`.
- Authenticated flow uses `TabView` with tabs: `.main`, `.profile`, `.console`.
- `.console` renders `PulseUI.ConsoleView()`.

To add a pushed screen:

1. Add a case to `Sources/Base/Navigation/RouterDestination.swift`.
2. If it should be deep-linkable, update `RouterDestination.from(path:fullPath:parameters:)`.
3. Map the case in `Sources/Template/Destinations/AppDestinations.swift`.
4. Navigate with `router.navigateTo(.yourDestination)` from a view that has `@Environment(AppRouter.self)`.

To add sheets or full-screen covers, add cases in `SheetDestination.swift` or `FullScreenDestination.swift`, update their parser methods, then map the UI in `Sources/Template/Destinations/SheetDestinations.swift` or `FullScreenDestinations.swift`.

## Deeplinks & Push

Deep links and pushes are generic routing infrastructure only. Do not add product/business actions to this layer.

`DeeplinkManager` accepts `template://` URLs through `open(url:)` and internal deeplink paths through `open(deeplink:)`, then emits business-level `DeeplinkEvent` values. It must not decide how to navigate. `AppRoot` owns opening behavior.

- `template://settings`
- `template://event/21`

Internal paths such as `/settings` and `/event/21` are supported for push payloads and other app-owned deeplink sources. Only add identifiers to events that actually need them; use slash-separated `entity/id` when an identifier exists. Unsupported URLs should emit `.url(String)` so `AppRoot` can decide whether to open them externally.

HTTP/HTTPS URLs are parsed by path when possible. Unsupported URLs become `.url(String)` so `AppRoot` can decide whether to open them through `openURL`.

Deeplinks are for authenticated users only. `AppRoot` should not queue deeplink events while unauthenticated. If a deeplink event arrives without a current user, ignore it and let the next explicit event drive navigation.

`PushNotificationsManager` is a thin adapter into the same deeplink pipeline. Push events should stay concrete, not raw dictionaries. Current cases are `.deeplink(String)` and `.alert(title: String, body: String)`. It parses:

- `deeplink`: internal entity path, for example `/settings` or `/event/21`
- `alert.title` and `alert.body`: generic alert content

Example alert payload: `{ "alert": { "title": "Template update", "body": "New demo content is available." } }`.

Unknown payloads are ignored by the template. Add new explicit `PushEvent` cases for product-specific actions instead of reintroducing an abstract raw payload event. `AppDelegate` forwards launch notifications, APNS token registration, and remote notification payloads to the manager.

`PushNotificationsManager.configure(client:)` stores the `NetworkClient` dependency and starts APNS registration. Backend token registration is explicit: call `registerDeviceTokenOnServer()` after the user is authenticated or from a screen that needs to enable push notifications. The template endpoint example is `POST /api/v1/push/device-token` with `PushDeviceTokenRequest`.

`PushPayloadParser` should keep a single entry point, `event(from:) -> PushEvent?`, so parsing order and payload shape stay encapsulated in one place.

## Dependency Injection

Environment injection is centralized in `Sources/Template/AppRegistry/AppDependencyGraph.swift`.

- `AppEnvironment` is a composition helper for shared app services. Flow-specific values such as `AppRouter`, `AppSimpleRouter`, and `CurrentUser` are passed separately where needed. Feature screens should still access concrete services through `@Environment(Type.self)`, not by passing this container around.
- Authenticated views receive `AppRouter`, `NetworkClient`, `CurrentUser`, `Auth`, `ToastManager`, `UserPreferences`, `PushNotificationsManager`, and `DeeplinkManager`.
- Unauthenticated views receive `AppSimpleRouter`, `Auth`, `NetworkClient`, `ToastManager`, `UserPreferences`, `PushNotificationsManager`, and `DeeplinkManager`.
- Sheet and full-screen destinations must re-inject the authenticated environment values so presented screens can subscribe to push/deeplink events or use app services directly.
- Shared service setup configures `Auth` with `NetworkClient` and initializes push notifications.

Prefer passing shared app services through SwiftUI environment (`@Environment(Type.self)`) instead of constructing duplicates inside feature views.

## Colors & Design

The template keeps only a minimal demo palette in `Sources/Base/Design/Resources/Colors.xcassets`: `black`, `white`, and `purple`. They are exposed through `Sources/Base/Design/Extensions/Color/Colors.swift`.

Use the typed accessors:

- `Color.Fill.*`

Use opacity variants at call sites for simple demo secondary states, for example `Color.Fill.black.opacity(0.55)`. Do not add product-specific color assets to the template; apps that adopt the template should replace or extend the palette for their own design system.

`HeaderView` is available as a shared component when a real feature needs a custom navigation/header bar. Demo screens intentionally avoid custom headers to keep navigation examples minimal.

Use `padding` for fixed spacing. Use `Spacer()` only when elements need to be pushed apart.

## Networking & Auth

`NetworkClient` wraps `URLSession` and exposes `request<T: Codable>(_:)` for typed JSON responses.

API endpoints implement `APIEndpoint` from `Sources/Base/Client/HTTP/API/APIEndpoint.swift`.

Endpoint defaults:

- host: `NetworkConst.currentHostUrl`
- path prefix: `/api`
- version: `.v1`
- content type: JSON
- token injection when `withToken = true`

`NetworkClient` handles 401 responses by asking `RefreshManager` to refresh once, then emits `authenticationExpiredUpdates` if auth is no longer valid. `AppRoot` listens to that stream and invalidates the session.

Tokens and serialized `User` data are stored via `KeychainWrapper` under keys from `AuthStorageKey`. Base URL configuration lives in `Sources/Base/Client/HTTP/NetworkConst.swift`; it currently points to `api.example.com` in release mode and `stage.api.example.com` when `isDebug` is set to `true`.

## Toasts

`ToastManager` lives in `Core` and is injected through the environment. `AppRoot` overlays `AppToast` at the top level, and modal/full-screen destination wrappers add their own overlay so toast messages remain visible above presented content.

Use `toastManager.show(message:type:)` for user-visible transient status.

## Adding a New Feature Module

1. Create `Sources/Features/YourFeatureUI/`.
2. Add a dynamic library product to `Package.swift`.
3. Add a target to `Package.swift`. Feature screens that need app services normally depend on `Design`, `Core`, `Client`, and `Navigation`.
4. Add the new target as a dependency of the `Template` target.
5. Import the module in `Sources/Template/Destinations/AppDestinations.swift`, `AppTabsRoot.swift`, or the relevant destination mapper.
6. Add navigation/destination cases if the feature has pushed, sheet, or full-screen screens.

Keep new modules aligned with the existing boundaries: feature modules should own screens and local UI, while shared networking, models, navigation primitives, and design assets belong under `Sources/Base`.
