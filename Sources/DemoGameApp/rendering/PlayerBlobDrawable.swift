import CustomGraphicsMath
import Foundation

public class PlayerBlobDrawable: BlobDrawable<PlayerBlob> {
    public var vertexCount: Int {
        return max(10, Int(sqrt(blobState.radius)) * 2)
    }
    public var acceleration: DVec2 = .zero

    override public func updateVertices() {
        let cyclicalProgress = lifetime.truncatingRemainder(dividingBy: 1)

        var vertices = [DPoint2]()
        var max = DPoint2(-.infinity, -.infinity)
        var min = DPoint2(.infinity, .infinity)

        for i in 0..<vertexCount {
            let angle = 2 * Double.pi / Double(vertexCount) * Double(i)
            let direction = DVec2(cos(angle), sin(angle))
            let radialOffset = direction * blobState.radius

            var accelerationWeight = acceleration.normalized().dot(direction) > 0 ? 1.0 : 0.0
            accelerationWeight *= acceleration.length / 50 // GameRule.maxAcceleration
            
            let accelerationStretch = blobState.radius * 0.1
            let accelerationOffset = acceleration.normalized() * accelerationStretch * accelerationWeight

            let maxWobbleHeight = cos(cyclicalProgress * Double.pi * 2) * blobState.radius * 0.05
            let wobblePeriodCount = floor(Double(vertexCount) * 0.5)
            var cyclicalOffset = direction * sin(angle * wobblePeriodCount + cyclicalProgress * Double.pi * 2) * maxWobbleHeight

            let vertex = blobState.position + radialOffset + cyclicalOffset + accelerationOffset
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
        }

        self.bounds = DRect(min: min, max: max)

        self.vertices = vertices
    }
}