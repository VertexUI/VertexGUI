import CSDL2
import CustomGraphicsMath

public extension DRect {
    func toSDL() -> SDL_Rect {
        return SDL_Rect(x: Int32(topLeft.x), y: Int32(topLeft.y), w: Int32(size.width), h: Int32(size.height))
    }
}