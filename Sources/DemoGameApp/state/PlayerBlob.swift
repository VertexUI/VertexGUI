import CustomGraphicsMath

public class PlayerBlob: Blob {
    public var id: UInt

    public let type: BlobType = .Player

    public var position: DVec2

    /// Mass. In MassUnits.
    public var mass: Double

    public var radius: Double

    public var consumed: Bool = false

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

    public var accelerationDirection: DVec2 = DVec2(0, 0)

    /// 0 - 1, Apply none of the possible acceleration or all of the possible acceleration.
    public var accelerationFactor: Double = 0

    /// The maximum acceleration possible.
    public var maxAcceleration: Double = 0

    /// Realised acceleration along both axes. LengthUnits per TimeUnit².
    public var acceleration: DVec2 = .zero

    /// LengthUnits per TimeUnit.
    public var speed: DVec2 = .zero

    public init(id: UInt, position: DVec2, mass: Double, radius: Double) {
        self.id = id
        self.position = position
        self.mass = mass
        self.radius = radius
    }
}