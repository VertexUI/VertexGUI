//
// SDLOpenGLWindowSurface.swift
// Fireblade Engine
//
// Copyright © 2018-2021 Fireblade Team. All rights reserved.
// Licensed under GNU General Public License v3.0. See LICENSE file for details.

#if FRB_PLATFORM_SDL && FRB_GRAPHICS_OPENGL
import GfxMath

@_implementationOnly import SDL2

public final class SDLOpenGLWindowSurface: SDLWindowSurface, OpenGLSurface {
    private weak var window: SDLWindow?
    public let glContext: SDLOpenGLContext

    public required init(in window: SDLWindow, with options: Void) throws {
        guard let glContext = SDL_GL_CreateContext(window._window) else {
            throw _Error.couldNotCreateOpenGLContext
        }

        self.window = window

        self.glContext = SDLOpenGLContext(window: window, internalContext: glContext)
    }

    public static func create(in window: Window) throws -> Self {
        try Self(in: window, with: ())
    }

    @inline(__always)
    public static var sdlFlags: UInt32 {
        SDL_WINDOW_OPENGL.rawValue
    }

    public var enableVsync: Bool {
        get { SDL_GL_GetSwapInterval() == 1 }
        set { SDL_GL_SetSwapInterval(newValue ? 1 : 0) }
    }

    public func getDrawableSize() -> Size<Int> {
        guard let window = window else {
            return Size(0, 0)
        }

        var w: Int32 = 0
        var h: Int32 = 0
        SDL_GL_GetDrawableSize(window._window, &w, &h)
        return Size(Int(w), Int(h))
    }

    public func swap() {
        guard let window = window else {
            return
        }
        SDL_GL_SwapWindow(window._window)
    }

    public func destroy() {
        glContext.destroy()
    }

    private enum _Error: Error {
        case couldNotCreateOpenGLContext
    }
}

// Fix for @_implementationOnly private property bug
// see: <https://bugs.swift.org/browse/SR-11910>
#if swift(<5.4)
private typealias SDLGLContext = UnsafeMutableRawPointer
#else
private typealias SDLGLContext = SDL_GLContext
#endif

public class SDLOpenGLContext: OpenGLContextBase {
    let window: SDLWindow

    private let _context: SDLGLContext

    fileprivate init(window: SDLWindow, internalContext: SDLGLContext) {
        self.window = window
        _context = internalContext
    }

    public func makeCurrent() {
        SDL_GL_MakeCurrent(window._window, _context)
    }

    public func destroy() {
        SDL_GL_DeleteContext(_context)
    }
}

#endif
