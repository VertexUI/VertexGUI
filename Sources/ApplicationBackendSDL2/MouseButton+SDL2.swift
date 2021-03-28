import Application
import CSDL2

extension MouseButton {
  init(fromSDL sdlMouseButton: UInt8) {
    if sdlMouseButton == UInt8(SDL_BUTTON_LEFT) {
      self = .left
    } else if sdlMouseButton == UInt8(SDL_BUTTON_RIGHT) {
      self = .right
    } else {
      fatalError("sdl mouse button not mapped: \(sdlMouseButton)")
    }
  }
}