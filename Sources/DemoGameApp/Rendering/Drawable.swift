import CustomGraphicsMath

public class Drawable {
    public internal(set) var vertices: [DPoint2] = []
 
    public internal(set) var bounds: DRect = DRect(min: .zero, max: .zero)

    public internal(set) var lifetime: Double = 0
}