// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "TouchPointKit",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "TouchPointKit", targets: ["TouchPointKit"])
    ],
    targets: [
        .binaryTarget(
            name: "TouchPointKit",
            path: "TouchPointKit.xcframework"
        )
    ]
)
