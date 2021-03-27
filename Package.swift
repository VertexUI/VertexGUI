// swift-tools-version:5.3
import Foundation
import PackageDescription

var conditionalVulkanImports = [PackageDescription.Target.Dependency]()
var conditionalVulkanDefines = [PackageDescription.SwiftSetting]()
conditionalVulkanDefines.append(.unsafeFlags([])) // need to add this, because can't pass empty array to swiftSettings

if let backends = ProcessInfo.processInfo.environment["SWIFT_GUI_ENABLE_BACKENDS"] {
    if backends.contains("vulkan") {
        conditionalVulkanImports.append(contentsOf: ["Vulkan", .product(name: "CSDL2Vulkan", package: "CSDL2")])
        conditionalVulkanDefines.append(.define("ENABLE_VULKAN"))
    }
}

let package = Package(
    name: "SwiftGUI",
    
    platforms: [
        .macOS(.v10_15)
    ],
    
    products: [
        .library(
            name: "SwiftGUI",
            targets: ["SwiftGUI", "ApplicationBackendSDL2"]
        ),
        .library(name: "ApplicationBackendSDL2", targets: ["ApplicationBackendSDL2"]),
        .executable(name: "MinimalDemo", targets: ["MinimalDemo"]),
        .executable(name: "DevApp", targets: ["DevApp"]),
        .executable(
            name: "TaskOrganizerDemo",
            targets: ["TaskOrganizerDemo"]),
    ],

    dependencies: [
        .package(url: "https://github.com/UnGast/CSDL2.git", .branch("master")),
        .package(name: "Vulkan", url: "https://github.com/UnGast/SwiftVulkan.git", .branch("master")),
        .package(url: "https://github.com/mxcl/Path.swift.git", .branch("master")),
        .package(name: "GL", url: "https://github.com/UnGast/swift-opengl.git", .branch("master")),
        .package(name: "Swim", url: "https://github.com/t-ae/swim.git", .branch("master")),
        .package(url: "https://github.com/UnGast/Cnanovg.git", .branch("master")),
        .package(name: "GfxMath", url: "https://github.com/UnGast/swift-gfx-math.git", .branch("master")),
        .package(url: "https://github.com/cx-org/CombineX.git", .branch("master")),
        .package(url: "https://github.com/mtynior/ColorizeSwift.git", from: "1.6.0"),
        .package(name: "GLUtils", url: "https://github.com/UnGast/swift-gl-utils", .branch("master"))
    ],

    targets: [
        .target(name: "Drawing", dependencies: ["GfxMath"] + conditionalVulkanImports, swiftSettings: conditionalVulkanDefines),
        .target(name: "Application", dependencies: ["Drawing", "GfxMath", "CombineX"]),
        .target(name: "ApplicationBackendSDL2", dependencies: ["Application", "Drawing", "CSDL2", "GfxMath", "CombineX"] + conditionalVulkanImports, swiftSettings: conditionalVulkanDefines),

        .target(
            name: "VisualAppBase", dependencies: ["CSDL2", "GfxMath", "Swim", .product(name: "Path", package: "Path.swift"), "Drawing"]
        ),

        .target(
            name: "Events"
        ),

        .target(
            name: "WidgetGUI",
            dependencies: ["VisualAppBase", "Events", .product(name: "CXShim", package: "CombineX"), "GfxMath", "ColorizeSwift"],
            resources: [.process("Resources")]
        ),

        .target(
            name: "VisualAppBaseImplSDL2OpenGL3NanoVG",
            dependencies: ["WidgetGUI", "CSDL2", "GL", "GLUtils", "Drawing", "Events", "Swim", .product(name: "CnanovgGL3", package: "Cnanovg"), "GfxMath", .product(name: "Path", package: "Path.swift")],
            resources: [.process("Resources")]),
       
        .target(
            name: "TaskOrganizerDemo",
            dependencies: ["SwiftGUI", "Swim", .product(name: "CXShim", package: "CombineX")],
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
            dependencies: ["VisualAppBase", "VisualAppBaseImplSDL2OpenGL3NanoVG", "WidgetGUI", "Events", "GfxMath", "Drawing", "Application"],
            resources: [.process("Resources")]
        ),

        //.testTarget(name: "WidgetGUITests", dependencies: ["SwiftGUI"])
    ]
)
