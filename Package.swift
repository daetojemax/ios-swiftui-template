// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Template",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Template", type: .dynamic, targets: ["Template"]),
        .library(name: "Design", type: .dynamic, targets: ["Design"]),
        .library(name: "Core", type: .dynamic, targets: ["Core"]),
        .library(name: "Models", type: .dynamic, targets: ["Models"]),
        .library(name: "Client", type: .dynamic, targets: ["Client"]),
        .library(name: "Navigation", type: .dynamic, targets: ["Navigation"]),
        .library(name: "AuthorizationUI", type: .dynamic, targets: ["AuthorizationUI"]),
        .library(name: "MainUI", type: .dynamic, targets: ["MainUI"]),
        .library(name: "ProfileUI", type: .dynamic, targets: ["ProfileUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", from: "24.0.0"),
        .package(url: "https://github.com/kean/Pulse.git", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "Template",
            dependencies: [
                "Design",
                "Core",
                "Client",
                "Navigation",
                "AuthorizationUI",
                "MainUI",
                "ProfileUI",
                .product(name: "PulseUI", package: "Pulse"),
            ]
        ),

        // MARK: Base modules
        .target(
            name: "Design",
            path: "Sources/Base/Design",
            resources: [
                .process("Resources"),
            ]
        ),

        .target(
            name: "Core",
            dependencies: [
                .product(name: "KeychainSwift", package: "keychain-swift"),
            ],
            path: "Sources/Base/Core"
        ),

        .target(
            name: "Models",
            path: "Sources/Base/Models"
        ),

        .target(
            name: "Client",
            dependencies: [
                "Models",
                "Core",
                .product(name: "Pulse", package: "Pulse"),
            ],
            path: "Sources/Base/Client"
        ),

        .target(
            name: "Navigation",
            dependencies: [
                "Design",
                "Models",
            ],
            path: "Sources/Base/Navigation"
        ),

        // MARK: Feature modules
        .target(
            name: "AuthorizationUI",
            dependencies: [
                "Design",
                "Core",
                "Client",
                "Navigation",
            ],
            path: "Sources/Features/AuthorizationUI"
        ),

        .target(
            name: "MainUI",
            dependencies: [
                "Design",
                "Core",
                "Client",
                "Navigation",
            ],
            path: "Sources/Features/MainUI"
        ),

        .target(
            name: "ProfileUI",
            dependencies: [
                "Design",
                "Core",
                "Client",
                "Navigation",
            ],
            path: "Sources/Features/ProfileUI"
        ),
    ]
)
