import Foundation
import CustomGraphicsMath

public class Blob {
    public enum Direction: CaseIterable {
        case Up, Right, Down, Left
    }

    private static var nextId: UInt = 0
    public internal(set) var id: UInt

    public var creationTimestamp: TimeInterval
    public var position: DVec2
    public internal(set) var mass: Double

    public var radius: Double {
        mass
    }

    public var throttles: [Direction: Bool] =
        Direction.allCases.reduce(into: [:]) {
            $0[$1] = false
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