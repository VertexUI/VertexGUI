import CSDL2
import WidgetGUI
import VisualAppBase

#if os(macOS)
fileprivate func asSDLKeycode(_ key: SDL_KeyCode) -> SDL_Keycode {
    SDL_Keycode(key.rawValue)
}

#elseif os(Linux)
fileprivate func asSDLKeycode(_ key: Int) -> SDL_Keycode {
    SDL_Keycode(key)
}
#endif


public extension Key {   
    init?(sdlKeycode: SDL_Keycode) {
        switch sdlKeycode {
        case asSDLKeycode(SDLK_RETURN): self = .Return 
        case asSDLKeycode(SDLK_KP_ENTER): self = .Enter
        case asSDLKeycode(SDLK_BACKSPACE): self = .Backspace
        case asSDLKeycode(SDLK_DELETE): self = .Delete
        case asSDLKeycode(SDLK_SPACE): self = .Space
        case asSDLKeycode(SDLK_ESCAPE): self = .Escape

        case asSDLKeycode(SDLK_UP): self = .ArrowUp
        case asSDLKeycode(SDLK_RIGHT): self = .ArrowRight
        case asSDLKeycode(SDLK_DOWN): self = .ArrowDown
        case asSDLKeycode(SDLK_LEFT): self = .ArrowLeft

        case asSDLKeycode(SDLK_LSHIFT): self = .LeftShift
        case asSDLKeycode(SDLK_LCTRL): self = .LeftCtrl
        case asSDLKeycode(SDLK_LALT): self = .LeftAlt

        case asSDLKeycode(SDLK_a): self = .A
        case asSDLKeycode(SDLK_s): self = .S
        case asSDLKeycode(SDLK_d): self = .D
        case asSDLKeycode(SDLK_w): self = .W

        case asSDLKeycode(SDLK_F1): self = .F1
        case asSDLKeycode(SDLK_F2): self = .F2
        case asSDLKeycode(SDLK_F3): self = .F3
        case asSDLKeycode(SDLK_F4): self = .F4
        case asSDLKeycode(SDLK_F5): self = .F5
        case asSDLKeycode(SDLK_F6): self = .F6
        case asSDLKeycode(SDLK_F7): self = .F7
        case asSDLKeycode(SDLK_F8): self = .F8
        case asSDLKeycode(SDLK_F9): self = .F9
        case asSDLKeycode(SDLK_F10): self = .F10
        case asSDLKeycode(SDLK_F11): self = .F11
        case asSDLKeycode(SDLK_F12): self = .F12
        default: return nil
        }
    }
}
