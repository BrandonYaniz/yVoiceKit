// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "yVoiceKit",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "yVoiceKit",
            targets: ["yVoiceKit"]
        ),
        .library(
            name: "yVoiceKitQwen",
            targets: ["yVoiceKitQwen"]
        )
    ],
    dependencies: [
        // Add yLLMKit after the model metadata/selection update is available.
        // .package(url: "https://github.com/BrandonYaniz/yllmkit.git", branch: "main"),

        // Add the selected native Swift/MLX Qwen dependency during Stage 4.
    ],
    targets: [
        .target(
            name: "yVoiceKit",
            dependencies: []
        ),
        .target(
            name: "yVoiceKitQwen",
            dependencies: [
                "yVoiceKit"
            ]
        ),
        .testTarget(
            name: "yVoiceKitTests",
            dependencies: ["yVoiceKit"]
        ),
        .testTarget(
            name: "yVoiceKitQwenTests",
            dependencies: [
                "yVoiceKit",
                "yVoiceKitQwen"
            ]
        )
    ]
)
