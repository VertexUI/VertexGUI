import CSDL2
import WidgetGUI
import VisualAppBase

public extension Key {
    init?(sdlKeycode: SDL_Keycode) {
        switch sdlKeycode {
        case SDL_Keycode(SDLK_UP): self = .ArrowTop
        case SDL_Keycode(SDLK_RIGHT): self = .ArrowRight
        case SDL_Keycode(SDLK_DOWN): self = .ArrowDown
        case SDL_Keycode(SDLK_LEFT): self = .ArrowLeft
        case SDL_Keycode(SDLK_a): self = .LA
        case SDL_Keycode(SDLK_s): self = .LS
        case SDL_Keycode(SDLK_d): self = .LD
        case SDL_Keycode(SDLK_w): self = .LW
        case SDL_Keycode(SDLK_ESCAPE): self = .Esc
        default: return nil
        }
    }
}