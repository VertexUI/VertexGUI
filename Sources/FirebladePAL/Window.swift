//
// Window.swift
// Fireblade Engine
//
// Copyright © 2018-2021 Fireblade Team. All rights reserved.
// Licensed under GNU General Public License v3.0. See LICENSE file for details.

#if FRB_PLATFORM_SDL
public typealias Window = SDLWindow
#elseif FRB_PLATFORM_APPL
public typealias Window = APPLWindow
#endif

public protocol WindowBase: AnyObject {
    typealias SurfaceConstructor<Surface> = (Window) throws -> Surface where Surface: WindowSurface

    /// Creates a window using given properties and surface constructor.
    /// - Parameters:
    ///   - properties: Window properties.
    ///   - surface: Window surface constructor to be used.
    ///              Surface type not be changed after window creation.
    init<Surface>(properties: WindowProperties, surface surfaceConstructor: @escaping SurfaceConstructor<Surface>) throws

    /// Creates a window using given properties and prepares
    /// the window for deferred surface creation using given surface type.
    /// - Parameters:
    ///   - properties: Window properties.
    ///   - surfaceType: The window surface type preparing the window for deferred surface creation.
    ///                  Override `createSurface(of:, in:)` to control deferred surface creation.
    ///                  Surface type not be changed after window creation.
    init(properties: WindowProperties, surfaceType: WindowSurface.Type) throws

    var windowID: Int { get }
    var title: String? { get set }
    var frame: Rect<Int> { get set }

    var fullscreen: Bool { get set }

    var screen: Screen? { get }

    static func createSurface(of surfaceType: WindowSurface.Type, in window: Window) throws -> WindowSurface
    var surfaceType: WindowSurface.Type { get }
    var surface: WindowSurface? { get }

    func close()
    func centerOnScreen()
}

public struct WindowProperties {
    public var title: String
    public var frame: Rect<Int>

    public init(title: String, frame: Rect<Int>) {
        self.title = title
        self.frame = frame
    }
}