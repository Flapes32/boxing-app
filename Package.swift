// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "BoxingApp",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BoxingApp", targets: ["BoxingApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
    ],
    targets: [
        .target(
            name: "BoxingApp",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
            ]
        ),
    ]
)
