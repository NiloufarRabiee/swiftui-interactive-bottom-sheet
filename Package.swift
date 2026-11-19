// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "InteractiveBottomSheet",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "InteractiveBottomSheet", targets: ["InteractiveBottomSheet"])
    ],
    targets: [
        .target(name: "InteractiveBottomSheet"),
        .testTarget(
            name: "InteractiveBottomSheetTests",
            dependencies: ["InteractiveBottomSheet"]
        )
    ]
)
