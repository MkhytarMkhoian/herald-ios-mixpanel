// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "herald-ios-mixpanel",
    // macOS is listed so the tests can run with `swift test` on a Mac.
    platforms: [.iOS(.v15), .macOS(.v13)],
    products: [
        .library(name: "HeraldMixpanel", targets: ["HeraldMixpanel"])
    ],
    dependencies: [
        .package(url: "https://github.com/MkhytarMkhoian/herald-ios", from: "1.0.0"),
        .package(url: "https://github.com/mixpanel/mixpanel-swift", from: "6.0.0"),
    ],
    targets: [
        .target(
            name: "HeraldMixpanel",
            dependencies: [
                .product(name: "HeraldCore", package: "herald-ios"),
                .product(name: "Mixpanel", package: "mixpanel-swift"),
            ]
        ),
        .testTarget(
            name: "HeraldMixpanelTests",
            dependencies: [
                "HeraldMixpanel",
                .product(name: "HeraldTesting", package: "herald-ios"),
            ]
        ),
    ]
)
