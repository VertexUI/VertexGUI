//
// SDLScreen.swift
// Fireblade Engine
//
// Copyright © 2018-2021 Fireblade Team. All rights reserved.
// Licensed under GNU General Public License v3.0. See LICENSE file for details.

#if FRB_PLATFORM_SDL
import GfxMath
@_implementationOnly import SDL2

public final class SDLScreen: ScreenBase {
    let displayIndex: Int32

    init(displayIndex: Int32) {
        self.displayIndex = displayIndex
    }

    private var currentDisplayMode: SDL_DisplayMode {
        var mode = SDL_DisplayMode()
        let result = SDL_GetCurrentDisplayMode(displayIndex, &mode)
        SDLAssert(result == 0)
        return mode
    }

    public var screenID: Int? {
        Int(displayIndex)
    }

    public var frame: Rect<Int> {
        var _rect = SDL_Rect()
        let result = SDL_GetDisplayUsableBounds(displayIndex, &_rect)
        SDLAssert(result == 0)

        return Rect(min: Vector2(Int(_rect.x),
                    Int(_rect.y)),
                    size: Size2(Int(_rect.w),
                    Int(_rect.h)))
    }

    public var scale: Float {
        var ddpi: Float = 0
        var hdpi: Float = 0
        var vdppi: Float = 0

        let result = SDL_GetDisplayDPI(displayIndex, &ddpi, &hdpi, &vdppi)
        SDLAssert(result == 0)
        #warning("❗TODO: convert dpi to scale")
        return ddpi
    }

    public var refreshRate: Int? {
        Int(currentDisplayMode.refresh_rate)
    }

    public var name: String? {
        guard let cName = SDL_GetDisplayName(displayIndex) else {
            return nil
        }
        return String(cString: cName)
    }

    public static var main: Screen {
        Screen(displayIndex: 0)
    }

    public static var screens: [Screen] {
        (0 ..< SDL_GetNumVideoDisplays()).map(Screen.init)
    }
}

#endif
