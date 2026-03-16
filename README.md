# iOS SwiftUI Template

A production-ready iOS app template with modular SPM architecture. Swift 6.2, iOS 17.0+, SwiftUI.

## Features

- Modular architecture with 9 SPM dynamic library targets
- Generic tab-based navigation with `Router`
- Auth flow with token-based authentication (Keychain storage)
- Design system with centralized colors, fonts, and reusable components
- Networking layer with `APIEndpoint` protocol
- Environment-based dependency injection

## Architecture

```
App/TemplateApp.swift                  @main entry point (Xcode target)
    └── Template                       App orchestration
        ├── Features/
        │   ├── AuthorizationUI        Login, Registration
        │   ├── MainUI                 Main tab
        │   └── ProfileUI              Profile, Settings
        └── Base/
            ├── Navigation             Router, tabs, destinations
            ├── Design                 UI components, colors, fonts
            ├── Client                 NetworkClient, Auth, API
            ├── Core                   ErrorManager, Keychain, utilities
            └── Models                 Data models, API types
```

## Getting Started

### Requirements

- Xcode 16.3+
- iOS 17.0+
- Swift 6.2

### Build & Run

```bash
# Open workspace in Xcode (always use workspace, not xcodeproj)
open Project.xcworkspace

# Verify compilation via SPM (macOS host)
swift build
```

## Adding a New Feature

1. Create `Sources/Features/YourFeatureUI/`
2. Add target and library product to `Package.swift`
3. Add as dependency to the `Template` target
4. Add destination case in `Sources/Base/Navigation/RouterDestination.swift`
5. Map it in `Sources/Template/Destinations/AppDestinations.swift`

## License

MIT
