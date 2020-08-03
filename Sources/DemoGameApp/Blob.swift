import Foundation
import CustomGraphicsMath

public class Blob {
    public enum Direction: CaseIterable {
        case Up, Right, Down, Left
    }

    public var creationTimestamp: TimeInterval
    public var position: DVec2
    public internal(set) var mass: Double

    public var radius: Double {
        mass
    }
    public internal(set) var vertices: [DPoint2] = []
    public internal(set) var bounds: DRect

    public var throttles: [Direction: Bool] =
        Direction.allCases.reduce(into: [:]) {
            $0[$1] = false
        }

    public internal(set) var consumed = false

    public var vertexCount: Int {
        return Int(radius * 2)
    }

    public init(position: DVec2, mass: Double, timestamp: TimeInterval) {
        self.position = position
        self.mass = mass
        self.creationTimestamp = timestamp
        self.bounds = DRect(center: position, size: DSize2.zero)
    }

    public func updateVertices(at timestamp: TimeInterval) {
        let cyclicalProgress = (timestamp - creationTimestamp).truncatingRemainder(dividingBy: 1)

        var vertices = [DPoint2]()
        var max = DPoint2(-.infinity, -.infinity)
        var min = DPoint2(.infinity, .infinity)

        for i in 0..<vertexCount {
            let angle = 2 * Double.pi / Double(vertexCount) * Double(i)
            let direction = DVec2(cos(angle), sin(angle))
            let radialOffset = direction * radius

            let maxWobbleHeight = cos(cyclicalProgress * Double.pi * 2) * 15
            let cyclicalOffset = direction * sin(angle * 30 + cyclicalProgress * Double.pi * 2) * maxWobbleHeight

            let vertex = position + radialOffset + cyclicalOffset
            vertices.append(vertex)

            if vertex.x < min.x {
                min.x = vertex.x
            }
            if vertex.y < min.y {
                min.y = vertex.y
            }
            if vertex.x > max.x {
                max.x = vertex.x
            }
            if vertex.y > max.y {
                max.y = vertex.y
            }

            // TODO: might need to calculate normals here already?
        }

        self.bounds = DRect(min: min, max: max)

        self.vertices = vertices
    }

    /*public func contains(point: DPoint2) {

    }*/

    public func consume(_ other: Blob) {
        self.mass += other.mass
        other.consumed = true
    }

    public func interact(with other: Blob) {
        if other.consumed {
            return
        }
        if
            self.mass > other.mass,
            (other.position - position).length - self.radius < other.radius / 2 {
                self.consume(other)
        } else if
            other.mass > self.mass,
            (other.position - position).length - other.radius < self.radius / 2 {
                other.consume(self)
        }
    }
}