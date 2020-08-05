import CustomGraphicsMath
import Foundation

public class FoodBlobDrawable: BlobDrawable<FoodBlob> {
    public var vertexCount: Int {
        return max(10, Int(blobState.radius))
    }

    override public func updateVertices() {
        //let cyclicalProgress = lifetime.truncatingRemainder(dividingBy: 1)

        var vertices = [DPoint2]()
        var max = DPoint2(-.infinity, -.infinity)
        var min = DPoint2(.infinity, .infinity)

        for i in 0..<vertexCount {
            let angle = 2 * Double.pi / Double(vertexCount) * Double(i)
            let direction = DVec2(cos(angle), sin(angle))
            let radialOffset = direction * blobState.radius

            //let maxWobbleHeight = cos(cyclicalProgress * Double.pi * 2) * 15

            let vertex = blobState.position + radialOffset
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