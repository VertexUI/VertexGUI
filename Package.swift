// swift-tools-version:5.3
import Foundation
import PackageDescription

let package = Package(
    name: "VertexGUI",
    
    platforms: [
        .macOS(.v10_15)
    ],
    
    products: [
        .library(
            name: "VertexGUI",
            targets: ["VertexGUI"]
        ),
        /*.library(name: "ApplicationBackendSDL2", targets: ["ApplicationBackendSDL2"]),
        .library(name: "ApplicationBackendSDL2Vulkan", targets: ["ApplicationBackendSDL2Vulkan"]),*/
        .executable(name: "MinimalDemo", targets: ["MinimalDemo"]),
        .executable(name: "DevApp", targets: ["DevApp"]),
        .executable(
            name: "TaskOrganizerDemo",
            targets: ["TaskOrganizerDemo"]),
    ],

    dependencies: [
        //.package(url: "https://github.com/UnGast/CSDL2.git", .branch("master")),
        //.package(name: "Vulkan", url: "https://github.com/UnGast/SwiftVulkan.git", .branch("master")),
        .package(name: "GL", url: "https://github.com/UnGast/swift-opengl.git", .branch("master")),
        .package(name: "Swim", url: "https://github.com/t-ae/swim.git", from: "3.9.0"),
        .package(url: "https://github.com/UnGast/Cnanovg.git", .branch("master")),
        .package(name: "GfxMath", url: "https://github.com/UnGast/swift-gfx-math.git", .branch("master")),
        .package(url: "https://github.com/OpenCombine/OpenCombine.git", from: "0.12.0"),
        .package(url: "https://github.com/mtynior/ColorizeSwift.git", from: "1.6.0"),
        .package(name: "FirebladeHID", path: "../FirebladeHID"),
        .package(path: "../SkiaKit")
    ],

    targets: [
        .target(
            name: "Drawing",
            dependencies: ["GfxMath", .product(name: "FirebladeHID", package: "FirebladeHID"), "Swim"]),

        .target(
            name: "Application",
            dependencies: [
                "WidgetGUI",
                .product(name: "FirebladeHID", package: "FirebladeHID"),
                "Drawing",
                "GfxMath",
                "GL"]),

        .target(
            name: "Events"
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
