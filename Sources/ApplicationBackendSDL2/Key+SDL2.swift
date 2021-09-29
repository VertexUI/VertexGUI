import SDL2
import Application

fileprivate func asSDLKeycode(_ key: Int) -> SDL_Keycode {
    SDL_Keycode(key)
}

fileprivate func asSDLKeycode<T: RawRepresentable>(_ key: T) -> SDL_Keycode where T.RawValue == UInt32 {
    SDL_Keycode(key.rawValue)
}

public extension Key {   
    init?(sdlKeycode: SDL_Keycode) {
        switch sdlKeycode {
        case asSDLKeycode(SDLK_RETURN): self = .return 
        case asSDLKeycode(SDLK_KP_ENTER): self = .enter
        case asSDLKeycode(SDLK_BACKSPACE): self = .backspace
        case asSDLKeycode(SDLK_DELETE): self = .delete
        case asSDLKeycode(SDLK_SPACE): self = .space
        case asSDLKeycode(SDLK_ESCAPE): self = .escape

        case asSDLKeycode(SDLK_UP): self = .arrowUp
        case asSDLKeycode(SDLK_RIGHT): self = .arrowRight
        case asSDLKeycode(SDLK_DOWN): self = .arrowDown
        case asSDLKeycode(SDLK_LEFT): self = .arrowLeft

        case asSDLKeycode(SDLK_LSHIFT): self = .leftShift
        case asSDLKeycode(SDLK_LCTRL): self = .leftCtrl
        case asSDLKeycode(SDLK_LALT): self = .leftAlt

        case asSDLKeycode(SDLK_a): self = .a
        case asSDLKeycode(SDLK_s): self = .s
        case asSDLKeycode(SDLK_d): self = .d
        case asSDLKeycode(SDLK_w): self = .w

        case asSDLKeycode(SDLK_PLUS): self = .plus
        case asSDLKeycode(SDLK_MINUS): self = .minus

        case asSDLKeycode(SDLK_F1): self = .f1
        case asSDLKeycode(SDLK_F2): self = .f2
        case asSDLKeycode(SDLK_F3): self = .f3
        case asSDLKeycode(SDLK_F4): self = .f4
        case asSDLKeycode(SDLK_F5): self = .f5
        case asSDLKeycode(SDLK_F6): self = .f6
        case asSDLKeycode(SDLK_F7): self = .f7
        case asSDLKeycode(SDLK_F8): self = .f8
        case asSDLKeycode(SDLK_F9): self = .f9
        case asSDLKeycode(SDLK_F10): self = .f10
        case asSDLKeycode(SDLK_F11): self = .f11
        case asSDLKeycode(SDLK_F12): self = .f12
        default: return nil
        }
    }
}
