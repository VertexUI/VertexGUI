// swift-tools-version:5.3

import PackageDescription

let package = Package(
    
    name: "SwiftGUI",
    
    platforms: [
        .macOS(.v10_15)
    ],
    
    products: [
        .library(
            name: "SwiftGUI",
            targets: ["SwiftGUI"]
        ),

        .executable(name: "MinimalDemo", targets: ["MinimalDemo"]),

        .executable(name: "DevApp", targets: ["DevApp"]),

        .executable(
            name: "TaskOrganizerDemo",
            targets: ["TaskOrganizerDemo"]),
    ],

    dependencies: [
        .package(url: "https://github.com/mxcl/Path.swift.git", .branch("master")),
        .package(name: "GL", url: "https://github.com/UnGast/swift-opengl.git", .branch("master")),
        .package(name: "Swim", url: "https://github.com/t-ae/swim.git", .branch("master")),
        .package(url: "https://github.com/UnGast/Cnanovg.git", .branch("master")),
        .package(url: "https://github.com/wickwirew/Runtime.git", from: "2.1.1"),
        .package(url: "https://github.com/mtynior/ColorizeSwift", .branch("master")),
        .package(url: "https://github.com/manuelCarlos/Easing.git", from: "2.0.0"),
        .package(name: "GfxMath", url: "https://github.com/UnGast/swift-gfx-math.git", .branch("master")),
        .package(name: "GLUtils", url: "https://github.com/UnGast/swift-gl-utils.git", .branch("master")),
        .package(url: "https://github.com/cx-org/CombineX.git", .branch("master"))
    ],

    targets: [
        .systemLibrary(
            name: "CSDL2",
            pkgConfig: "sdl2",
            providers: [
                .brew(["sdl2"]),
                .apt(["libsdl2-dev"])
        ]),

        .target(
            name: "VisualAppBase", dependencies: ["CSDL2", "GfxMath", "Swim", .product(name: "Path", package: "Path.swift")]
        ),

        .target(
            name: "Events"
        ),

        .target(
            name: "WidgetGUI",
            dependencies: ["VisualAppBase", "Events", .product(name: "CXShim", package: "CombineX"), "GfxMath", "Runtime", "ColorizeSwift", "Easing"],
            resources: [.process("Resources")]
        ),

        .target(
            name: "VisualAppBaseImplSDL2OpenGL3NanoVG",
            dependencies: ["WidgetGUI", "CSDL2", "GL", "Events", "GLUtils", "Swim", .product(name: "CnanovgGL3", package: "Cnanovg"), "GfxMath", .product(name: "Path", package: "Path.swift")],
            resources: [.process("Resources")]),
       
        .target(
            name: "TaskOrganizerDemo",
            dependencies: ["SwiftGUI", "ColorizeSwift", "Swim", .product(name: "CXShim", package: "CombineX")],
            resources: [.copy("Resources")]),

        .target(
            name: "MinimalDemo",
            dependencies: ["SwiftGUI"]
        ),

        .target(
            name: "DevApp",
            dependencies: ["SwiftGUI"]
        ),

        .target(
            name: "SwiftGUI",
            dependencies: ["VisualAppBase", "VisualAppBaseImplSDL2OpenGL3NanoVG", "WidgetGUI", "Events", "GfxMath"],
            resources: [.process("Resources")]
        ),

        .testTarget(name: "WidgetGUITests", dependencies: ["SwiftGUI"])
    ]
)
