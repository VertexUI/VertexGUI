import Foundation
import CustomGraphicsMath

public class Blob {
    private static var nextId: UInt = 0
    public internal(set) var id: UInt

    public var type: BlobType {
        fatalError("type not implemented.")
    }

    public var creationTimestamp: TimeInterval
    public var position: DVec2

    /// Mass. In MassUnits.
    public internal(set) var mass: Double

    public var radius: Double {
        mass
    }
    public internal(set) var consumed = false

    public var vertexCount: Int {
        return Int(radius * 2)
    }

    public init(position: DVec2, mass: Double, timestamp: TimeInterval) {
        self.id = Blob.nextId
        Blob.nextId += 1
        self.position = position
        self.mass = mass
        self.creationTimestamp = timestamp
    }
}