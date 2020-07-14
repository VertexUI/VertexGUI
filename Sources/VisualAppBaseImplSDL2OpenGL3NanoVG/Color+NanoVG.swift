import Cnanovg
import CustomGraphicsMath

public extension Color {
    public func toNVG() -> NVGcolor {
        return nvgRGBA(r, g, b, a)
    }
}