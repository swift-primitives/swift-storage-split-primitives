// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-storage-split-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        // MARK: - Store.Split (the dual-plane store combinator)
        .library(name: "Store Split Primitives", targets: ["Store Split Primitives"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-index-primitives.git", branch: "main"),
        // Test-only: concrete Storage.Contiguous planes to compose under Store.Split.
        .package(url: "https://github.com/swift-primitives/swift-storage-primitives.git", branch: "main"),
    ],
    targets: [

        // MARK: - Store.Split combinator
        .target(
            name: "Store Split Primitives",
            dependencies: [
                .product(name: "Store Primitive", package: "swift-storage-primitives"),
                .product(name: "Store Protocol Primitives", package: "swift-storage-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
            ]
        ),

        // MARK: - Tests
        .testTarget(
            name: "Store Split Primitives Tests",
            dependencies: [
                "Store Split Primitives",
                .product(name: "Storage Contiguous Primitives", package: "swift-storage-primitives"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = [
        .enableExperimentalFeature("RawLayout"),
    ]

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
