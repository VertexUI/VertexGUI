import Cnanovg
import CustomGraphicsMath

public extension Color {
    func toNVG() -> NVGcolor {
        return nvgRGBA(r, g, b, a)
    }
}
