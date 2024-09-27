// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "CombineRextensions",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(name: "CombineRextensions", targets: ["CombineRextensions"])
    ],
    dependencies: [
        .package(name: "SwiftRex", url: "https://github.com/SwiftRex/SwiftRex.git", from: "0.8.8"),
        .package(name: "UIExtensions", url: "https://github.com/TeufelAudio/UIExtensions.git", from: "2.0.0")
    ],
    targets: [
        .target(name: "CombineRextensions",
                dependencies: [
                    .product(name: "CombineRex", package: "SwiftRex"),
                    .product(name: "UIExtensions", package: "UIExtensions")
                ])
    ]
)
