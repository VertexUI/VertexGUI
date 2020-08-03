import CustomGraphicsMath
import Foundation

public class DrawableBlob {
    public let id: UInt
    public var creationTimestamp: Double
    public var position: DPoint2
    public var radius: Double
    public var vertexCount: Int {
        return Int(radius * 2)
    }
    public internal(set) var vertices: [DPoint2] = []
    public internal(set) var bounds: DRect
    public var consumed: Bool = false

    public init(id: UInt, position: DPoint2, radius: Double, creationTimestamp: Double) {
        self.id = id
        self.position = position
        self.radius = radius
        self.bounds = DRect(center: position, size: DSize2.zero)
        self.creationTimestamp = creationTimestamp
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
}