# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

iOS app template with modular SPM architecture. Pure iOS (no cross-platform). Swift 6.2, iOS 17.0+, SwiftUI.

## Build & Run

```bash
# SPM build (macOS host, verifies compilation)
swift build

# iOS build — open Project.xcworkspace in Xcode, run "template" target on simulator
open Project.xcworkspace
```

The Xcode project lives in `App/Template.xcodeproj`. The workspace at root references it and auto-discovers `Package.swift` for SPM resolution. Do NOT open the xcodeproj directly — always use `Project.xcworkspace`.

## Architecture

**9 SPM dynamic library targets + 1 Xcode app target:**

```
App/TemplateApp.swift              @main entry point (Xcode target)
    └── Template module            App orchestration (AppRoot, AppState, AppTabView, Destinations)
        ├── Features/
        │   ├── AuthorizationUI    Login, Registration screens
        │   ├── MainUI             Main tab screen
        │   └── ProfileUI          Profile, Settings screens
        └── Base/
            ├── Navigation         Generic Router, SimpleRouter, AppTab, destinations
            ├── Design             UI components, colors, fonts, images (has Resources/)
            ├── Client             NetworkClient, Auth, CurrentUser, API endpoints
            ├── Core               ErrorManager, KeychainWrapper, Haptic, validation wrappers
            └── Models             User, Token, Empty, API response types
```

**Dependency graph:** Design/Core/Models are standalone → Navigation depends on Design+Models → Client depends on Models+Core → Features depend on all base modules → Template depends on everything.

## Key Patterns

### Navigation
Generic `Router<Tab, Destination, Sheet, FullScreen>` manages per-tab NavigationStack paths. `AppRouter` is a typealias preconfigured with `AppTab`, `RouterDestination`, `SheetDestination`, `FullScreenDestination`. Add new screens by:
1. Adding a case to `RouterDestination` in `Sources/Base/Navigation/RouterDestination.swift`
2. Mapping it in `Sources/Template/Destinations/AppDestinations.swift`
3. Calling `router.navigateTo(.yourDestination)` from any view with `@Environment(AppRouter.self)`

Auth flow uses `AppSimpleRouter` (single-stack, no tabs) wrapped in its own NavigationStack in `AppRoot`.

### State Management
- `AppState` enum drives root view switching: `.loading` → `.authenticated` / `.unauthenticated`
- `Auth` emits `AuthConfiguration?` via `AsyncStream` — `AppRoot` listens and switches state
- All managers (`ErrorManager`, `Auth`, `NetworkClient`, `CurrentUser`) injected via `@Environment`
- State properties must NOT be `private` — keep `internal` or `public`

### Colors & Design
All colors defined in `Sources/Base/Design/Resources/Colors.xcassets`, accessed via `Color.Fill.*`, `Color.Text.*`, `Color.BG.*`. Never use raw hex/rgb colors.

Always use `HeaderView` for navigation bars (types: `.navigation`, `.modal`, `.titleOnly`, `.custom`, `.transparent`).

Use `padding` for fixed spacing. `Spacer()` only for pushing elements apart.

### Networking
`NetworkClient` wraps URLSession with JSON encode/decode. API endpoints implement `APIEndpoint` protocol. Token stored in Keychain via `KeychainWrapper` (Security.framework). Auth header injected automatically when `withToken = true`.

Base URL configured in `Sources/Base/Client/HTTP/NetworkConst.swift` — currently `api.example.com`.

## Adding a New Feature Module

1. Create directory `Sources/Features/YourFeatureUI/`
2. Add target to `Package.swift` with dependencies on Design, Core, Client, Navigation
3. Add library product
4. Add as dependency to Template target
5. Import in `AppDestinations.swift` for navigation mapping
