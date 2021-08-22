//
// SDLMTLSurface.swift
// Fireblade Engine
//
// Copyright © 2018-2021 Fireblade Team. All rights reserved.
// Licensed under GNU General Public License v3.0. See LICENSE file for details.

#if FRB_PLATFORM_SDL && FRB_GRAPHICS_METAL

import func Metal.MTLCreateSystemDefaultDevice
import protocol Metal.MTLDevice
import class QuartzCore.CAMetalLayer
@_implementationOnly import SDL2

import FirebladeMath

open class SDLMTLWindowSurface: SDLWindowSurface, MTLWindowSurfaceBase {
    private weak var _window: SDLWindow?

    #if swift(<5.4) // <https://bugs.swift.org/browse/SR-11910>
    private var mtlView: UnsafeMutableRawPointer!
    #else
    private var mtlView: SDL_MetalView!
    #endif

    public var layer: CAMetalLayer?

    public static var sdlFlags: UInt32 = SDL_WINDOW_METAL.rawValue

    public var enableVsync: Bool {
        get { layer?.displaySyncEnabled ?? false }
        set { layer?.displaySyncEnabled = newValue }
    }

    public required init(in window: SDLWindow, device: MTLDevice?) throws {
        guard let mtlView = SDL_Metal_CreateView(window._window) else {
            throw SDLError()
        }
        self.mtlView = mtlView

        let mtlLayer = unsafeBitCast(SDL_Metal_GetLayer(mtlView), to: CAMetalLayer.self)

        self._window = window
        self.layer = mtlLayer
        if let device = device {
            mtlLayer.device = device
        }
    }

    public static func create(in window: Window) throws -> Self {
        try Self(in: window, device: MTLCreateSystemDefaultDevice())
    }

    deinit {
        destroy()
    }

    public func destroy() {
        SDL_Metal_DestroyView(mtlView)
        mtlView = nil
        self.layer = nil
        self._window = nil
    }

    public func getDrawableSize() -> Size<Int> {
        guard let window = _window else {
            return Size(width: -1, height: -1)
        }
        var w: Int32 = 0
        var h: Int32 = 0
        SDL_Metal_GetDrawableSize(window._window, &w, &h)
        return Size(width: Int(w), height: Int(h))
    }
}

#endif
