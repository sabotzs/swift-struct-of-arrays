// swift-tools-version: 6.3

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "swift-struct-of-arrays",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "SwiftStructOfArrays",
            targets: ["SwiftStructOfArrays"]
        ),
        .executable(
            name: "SwiftStructOfArraysClient",
            targets: ["SwiftStructOfArraysClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "603.0.0-latest"),
    ],
    targets: [
        .macro(
            name: "SwiftStructOfArraysMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(name: "SwiftStructOfArrays", dependencies: ["SwiftStructOfArraysMacros"]),
        .executableTarget(name: "SwiftStructOfArraysClient", dependencies: ["SwiftStructOfArrays"]),
        .testTarget(
            name: "SwiftStructOfArraysTests",
            dependencies: [
                "SwiftStructOfArraysMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
