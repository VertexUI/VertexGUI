//
// Screen.swift
// Fireblade Engine
//
// Copyright © 2018-2021 Fireblade Team. All rights reserved.
// Licensed under GNU General Public License v3.0. See LICENSE file for details.

#if FRB_PLATFORM_SDL
public typealias Screen = SDLScreen
#elseif FRB_PLATFORM_APPL
public typealias Screen = APPLScreen
#endif

public protocol ScreenBase: AnyObject {
    var frame: Rect<Int> { get }

    var screenID: Int? { get }

    var refreshRate: Int? { get }

    var name: String? { get }

    static var main: Screen { get }

    static var screens: [Screen] { get }
}

extension Screen: CustomDebugStringConvertible {
    public var debugDescription: String {
        "<Screen id:\(screenID ?? -1) name:\(name ?? "") refreshRate:\(refreshRate ?? -1) scale:\(scale) frame:\(frame)>"
    }
}
