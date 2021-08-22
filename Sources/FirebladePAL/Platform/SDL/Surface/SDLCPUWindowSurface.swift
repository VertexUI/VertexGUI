//
// SDLCPUWindowSurface.swift
// Fireblade Engine
//
// Copyright © 2018-2021 Fireblade Team. All rights reserved.
// Licensed under GNU General Public License v3.0. See LICENSE file for details.

#if FRB_PLATFORM_SDL
import GfxMath

@_implementationOnly import SDL2

public final class SDLCPUWindowSurface: SDLWindowSurface, CPUWindowSurfaceBase {
    private typealias SDLSurfacePointer = UnsafeMutablePointer<SDL_Surface>

    public static let sdlFlags: UInt32 = 0
    private unowned var window: SDLWindow
    private var _surfacePtr: SDLSurfacePointer

    @discardableResult
    private func withSurfacePointer<T>(_ closure: (SDLSurfacePointer) -> T) -> T {
        closure(UnsafeMutablePointer(_surfacePtr))
    }

    public private(set) var buffer: UnsafeMutableBufferPointer<UInt8>

    public required init(in window: SDLWindow) throws {
        self.window = window
        (_surfacePtr, buffer) = try Self.mapSDLSurface(window: window)
    }

    public static func create(in window: Window) throws -> Self {
        try Self(in: window)
    }

    private static func mapSDLSurface(window: SDLWindow) throws -> (SDLSurfacePointer, UnsafeMutableBufferPointer<UInt8>) {
        guard let sdlSurface = SDL_GetWindowSurface(window._window) else {
            throw SDLError()
        }

        let buffer = UnsafeMutableBufferPointer(
            start: sdlSurface.pointee.pixels.bindMemory(to: UInt8.self, capacity: 1),
            count: Int(sdlSurface.pointee.w) * Int(sdlSurface.pointee.h) * 4
        )

        return (SDLSurfacePointer(sdlSurface), buffer)
    }

    public var enableVsync: Bool {
        get { false }
        set {}
    }

    public func handleWindowResize() throws {
        (_surfacePtr, buffer) = try Self.mapSDLSurface(window: window)
    }

    public func getDrawableSize() -> Size<Int> {
        withSurfacePointer { Size(Int($0.pointee.w), Int($0.pointee.h)) }
    }

    public func lock() {
        withSurfacePointer { SDL_LockSurface($0) }
    }

    public func unlock() {
        withSurfacePointer { SDL_UnlockSurface($0) }
    }

    public func clear() {
        withSurfacePointer { surfacePtr in
            lock()
            SDL_memset(surfacePtr.pointee.pixels, 255, Int(surfacePtr.pointee.h * surfacePtr.pointee.pitch))
            unlock()
        }
    }

    public func flush() {
        SDL_UpdateWindowSurface(window._window)
    }

    public func destroy() {}
}

#endif
