import Foundation
import CustomGraphicsMath

public class Blob {
    public var creationTimestamp: TimeInterval = 0
    public var position: DVec2
    public internal(set) var radius: Double = 100

    public internal(set) var vertices: [DPoint2] = []
    public internal(set) var bounds: DRect

    public var vertexCount: Int {
        return Int(radius * 2)
    }

    public init(position: DVec2, timestamp: TimeInterval) {
        self.position = position
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

            let maxWobbleHeight = cos(cyclicalProgress * Double.pi * 2) * 10
            let cyclicalOffset = direction * sin(angle * 20 + cyclicalProgress * Double.pi * 2) * maxWobbleHeight

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

    public func contains(point: DPoint2) {

    }



    public func interact(other: Blob) {
        for ownVertex in vertices {
            let direction = ownVertex - position

        }
    }
}