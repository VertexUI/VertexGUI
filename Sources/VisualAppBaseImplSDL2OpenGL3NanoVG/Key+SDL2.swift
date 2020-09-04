import CSDL2
import WidgetGUI
import VisualAppBase

public extension Key {
    init?(sdlKeycode: SDL_Keycode) {
        switch sdlKeycode {
        case SDL_Keycode(SDLK_RETURN): self = .Return 
        case SDL_Keycode(SDLK_KP_ENTER): self = .Enter
        case SDL_Keycode(SDLK_BACKSPACE): self = .Backspace
        case SDL_Keycode(SDLK_DELETE): self = .Delete
        case SDL_Keycode(SDLK_SPACE): self = .Space
        case SDL_Keycode(SDLK_ESCAPE): self = .Escape

        case SDL_Keycode(SDLK_UP): self = .ArrowUp
        case SDL_Keycode(SDLK_RIGHT): self = .ArrowRight
        case SDL_Keycode(SDLK_DOWN): self = .ArrowDown
        case SDL_Keycode(SDLK_LEFT): self = .ArrowLeft

        case SDL_Keycode(SDLK_a): self = .A
        case SDL_Keycode(SDLK_s): self = .S
        case SDL_Keycode(SDLK_d): self = .D
        case SDL_Keycode(SDLK_w): self = .W

        case SDL_Keycode(SDLK_F1): self = .F1
        case SDL_Keycode(SDLK_F2): self = .F2
        case SDL_Keycode(SDLK_F3): self = .F3
        case SDL_Keycode(SDLK_F4): self = .F4
        case SDL_Keycode(SDLK_F5): self = .F5
        case SDL_Keycode(SDLK_F6): self = .F6
        case SDL_Keycode(SDLK_F7): self = .F7
        case SDL_Keycode(SDLK_F8): self = .F8
        case SDL_Keycode(SDLK_F9): self = .F9
        case SDL_Keycode(SDLK_F10): self = .F10
        case SDL_Keycode(SDLK_F11): self = .F11
        case SDL_Keycode(SDLK_F12): self = .F12
        default: return nil
        }
    }
}