import Foundation
import CustomGraphicsMath

public struct Blob {
    public var creationTimestamp: TimeInterval = 0
    public var position: DVec2
    public internal(set) var radius: Double = 100

    public var vertexCount: Int {
        return Int(radius * 10)
    }

    public init(position: DVec2, timestamp: TimeInterval) {
        self.position = position
        self.creationTimestamp = timestamp
    }

    public func generateVertices(at timestamp: TimeInterval) -> [DVec2] {
        let cyclicalProgress = (timestamp - creationTimestamp).truncatingRemainder(dividingBy: 1)

        var vertices = [DPoint2]()

        for i in 0..<vertexCount {
            let angle = 2 * Double.pi / Double(vertexCount) * Double(i)
            let direction = DVec2(cos(angle), sin(angle))
            let radialOffset = direction * radius

            let maxWobbleHeight = cos(cyclicalProgress * Double.pi * 2) * 10
            let cyclicalOffset = direction * sin(angle * 20 + cyclicalProgress * Double.pi * 2) * maxWobbleHeight

            vertices.append(position + radialOffset + cyclicalOffset)
        }

        return vertices
    }
}