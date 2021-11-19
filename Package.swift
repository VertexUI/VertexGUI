// swift-tools-version:5.3
import Foundation
import PackageDescription

let package = Package(
    name: "VertexGUI",
    
    platforms: [
        .macOS(.v11)
    ],
    
    products: [
        .library(
            name: "VertexGUI",
            targets: ["VertexGUI"]
        ),
        .executable(name: "MinimalDemo", targets: ["MinimalDemo"]),
        .executable(name: "DevApp", targets: ["DevApp"]),
        .executable(
            name: "TaskOrganizerDemo",
            targets: ["TaskOrganizerDemo"]),
    ],

    dependencies: [
        .package(name: "GL", url: "https://github.com/UnGast/swift-opengl", .branch("master")),
        .package(name: "Swim", url: "https://github.com/UnGast/swim.git", .branch("master")),
        .package(name: "GfxMath", url: "https://github.com/UnGast/swift-gfx-math.git", .branch("master")),
        .package(url: "https://github.com/OpenCombine/OpenCombine.git", .branch("master")),
        .package(url: "https://github.com/mtynior/ColorizeSwift.git", from: "1.6.0"),
        .package(url: "https://github.com/UnGast/SkiaKit", .branch("main")),
        .package(name: "FirebladePAL", url: "https://github.com/fireblade-engine/pal.git", .branch("main"))
    ],

    targets: [
        .target(
            name: "Drawing",
            dependencies: ["GfxMath", "FirebladePAL", "Swim"]),

        .target(
            name: "Application",
            dependencies: [
                "WidgetGUI",
                "FirebladePAL",
                "Drawing",
                "GfxMath",
                "GL"]),

        .target(
            name: "Events",
            dependencies: ["OpenCombine"]
        ),

        .target(
            name: "WidgetGUI",
            dependencies: ["Events", "OpenCombine", .product(name: "OpenCombineDispatch", package: "OpenCombine"), "GfxMath", "ColorizeSwift", "Drawing", "SkiaKit"],
            resources: [.process("Resources")]
        ),

        .target(
            name: "TaskOrganizerDemo",
            dependencies: ["VertexGUI", "Swim", "OpenCombine"],
            resources: [.copy("Resources")]),

        .target(
            name: "MinimalDemo",
            dependencies: ["VertexGUI"]
        ),

        .target(
            name: "DevApp",
            dependencies: ["VertexGUI", "Swim"]
        ),

        .target(
            name: "VertexGUI",
            dependencies: ["WidgetGUI", "Events", "GfxMath", "Application", "Drawing"],
            resources: [.process("Resources")]
        ),

        //.testTarget(name: "WidgetGUITests", dependencies: ["VertexGUI"])
    ]
)
