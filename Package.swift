// swift-tools-version: 6.0

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "swift-util-macros",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13),
    ],
    products: [
        .library(
            name: "SwiftUtilMacros",
            targets: ["SwiftUtilMacros"]
        ),
        .executable(
            name: "SwiftUtilMacrosClient",
            targets: ["SwiftUtilMacrosClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "600.0.0-latest")
    ],
    targets: [
        .macro(
            name: "SwiftUtilMacrosPlugin",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "SwiftUtilMacros",
            dependencies: [
                .target(name: "SwiftUtilMacrosPlugin")
            ]
        ),
        .executableTarget(
            name: "SwiftUtilMacrosClient",
            dependencies: [
                .target(name: "SwiftUtilMacros")
            ]
        ),
        .testTarget(
            name: "SwiftUtilMacrosPluginTests",
            dependencies: [
                .target(name: "SwiftUtilMacrosPlugin"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
