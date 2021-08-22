//
// SDLPlatform.swift
// Fireblade Engine
//
// Copyright © 2018-2021 Fireblade Team. All rights reserved.
// Licensed under GNU General Public License v3.0. See LICENSE file for details.

#if FRB_PLATFORM_SDL

@_implementationOnly import SDL2

enum SDLPlatform: PlatformInitialization {
    static func initialize() {
        var result = SDL_InitSubSystem(SDL_INIT_VIDEO)
        SDLAssert(result == 0)

        result = SDL_InitSubSystem(SDL_INIT_EVENTS)
        SDLAssert(result == 0)
    }

    static var version: String {
        var compiled = SDL_version()
        compiled.major = Uint8(SDL_MAJOR_VERSION)
        compiled.minor = Uint8(SDL_MINOR_VERSION)
        compiled.patch = Uint8(SDL_PATCHLEVEL)

        var linked = SDL_version()
        SDL_GetVersion(&linked)

        if compiled.semanticVersion == linked.semanticVersion {
            return "SDL \(compiled.semanticVersion)"
        } else {
            return "SDL compiled:\(compiled.semanticVersion) linked:\(linked.semanticVersion)"
        }
    }

    static func quit() {
        SDL_QuitSubSystem(SDL_INIT_EVENTS)
        SDL_QuitSubSystem(SDL_INIT_VIDEO)
    }
}

extension SDL_version {
    var semanticVersion: String {
        "\(major).\(minor).\(patch)"
    }
}

#endif
