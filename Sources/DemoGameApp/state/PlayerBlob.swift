import CustomGraphicsMath

public class PlayerBlob: Blob {
    /// Perpendicular distance to the sides of a square.
    public var visionDistance: Double {
        radius * 5
    }
    public var fieldOfVision: DRect {
        DRect(
            min: position - DVec2(visionDistance, visionDistance),
            max: position + DVec2(visionDistance, visionDistance))
    }
    public var perspective: GamePerspective {
        GamePerspective(visibleArea: fieldOfVision)
    }
}