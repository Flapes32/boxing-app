// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "BoxingApp",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BoxingApp", targets: ["BoxingApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.33.0"),
    ],
    targets: [
        .target(
            name: "BoxingApp",
            dependencies: [
                .product(name: "RealmSwift", package: "realm-swift"),
            ],
            path: "final"
        ),
    ]
)
