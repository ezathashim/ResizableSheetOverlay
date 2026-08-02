// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ResizableSheetOverlay",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "ResizableSheetOverlay",
            targets: ["ResizableSheetOverlay"]
        ),
    ],
    targets: [
        .target(
            name: "ResizableSheetOverlay",
            resources: [
                .process("Resources")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
