import Foundation
import CustomGraphicsMath

public struct FoodBlob: Blob {
    public var id: UInt

    public let type: BlobType = .Food

    public var position: DVec2

    /// Mass. In MassUnits.
    public var mass: Double

    public var radius: Double

    public var consumed: Bool = false

    public init(id: UInt, position: DVec2, mass: Double, radius: Double) {
        self.id = id
        self.position = position
        self.mass = mass
        self.radius = radius
    }
}