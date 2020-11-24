import CSDL2
import WidgetGUI
import VisualAppBase

public extension Key {
    init?(sdlKeycode: SDL_Keycode) {
        switch sdlKeycode {
        case SDL_Keycode(SDLK_RETURN.rawValue): self = .Return 
        case SDL_Keycode(SDLK_KP_ENTER.rawValue): self = .Enter
        case SDL_Keycode(SDLK_BACKSPACE.rawValue): self = .Backspace
        case SDL_Keycode(SDLK_DELETE.rawValue): self = .Delete
        case SDL_Keycode(SDLK_SPACE.rawValue): self = .Space
        case SDL_Keycode(SDLK_ESCAPE.rawValue): self = .Escape

        case SDL_Keycode(SDLK_UP.rawValue): self = .ArrowUp
        case SDL_Keycode(SDLK_RIGHT.rawValue): self = .ArrowRight
        case SDL_Keycode(SDLK_DOWN.rawValue): self = .ArrowDown
        case SDL_Keycode(SDLK_LEFT.rawValue): self = .ArrowLeft

        case SDL_Keycode(SDLK_LSHIFT.rawValue): self = .LeftShift
        case SDL_Keycode(SDLK_LCTRL.rawValue): self = .LeftCtrl
        case SDL_Keycode(SDLK_LALT.rawValue): self = .LeftAlt

        case SDL_Keycode(SDLK_a.rawValue): self = .A
        case SDL_Keycode(SDLK_s.rawValue): self = .S
        case SDL_Keycode(SDLK_d.rawValue): self = .D
        case SDL_Keycode(SDLK_w.rawValue): self = .W

        case SDL_Keycode(SDLK_F1.rawValue): self = .F1
        case SDL_Keycode(SDLK_F2.rawValue): self = .F2
        case SDL_Keycode(SDLK_F3.rawValue): self = .F3
        case SDL_Keycode(SDLK_F4.rawValue): self = .F4
        case SDL_Keycode(SDLK_F5.rawValue): self = .F5
        case SDL_Keycode(SDLK_F6.rawValue): self = .F6
        case SDL_Keycode(SDLK_F7.rawValue): self = .F7
        case SDL_Keycode(SDLK_F8.rawValue): self = .F8
        case SDL_Keycode(SDLK_F9.rawValue): self = .F9
        case SDL_Keycode(SDLK_F10.rawValue): self = .F10
        case SDL_Keycode(SDLK_F11.rawValue): self = .F11
        case SDL_Keycode(SDLK_F12.rawValue): self = .F12
        default: return nil
        }
    }
}