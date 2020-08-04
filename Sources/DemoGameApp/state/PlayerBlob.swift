import CustomGraphicsMath

public class PlayerBlob: Blob {
    override open var type: BlobType {
        .Player
    }

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

    public var throttles: [MoveDirection: Bool] =
        MoveDirection.allCases.reduce(into: [:]) {
            $0[$1] = false
        }

    /// Realised acceleration along both axes. LengthUnits per TimeUnit².
    public var acceleration: DVec2 = .zero

    /// LengthUnits per TimeUnit.
    public var speed: DVec2 = .zero
}