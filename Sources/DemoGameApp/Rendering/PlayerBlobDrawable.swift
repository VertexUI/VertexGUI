import CustomGraphicsMath
import Foundation

public class PlayerBlobDrawable: BlobDrawable<PlayerBlob> {
    private struct WobbleConfig {
        public var angle: Double
        public var ease: (_ x: Double) -> Double
    }

    private var wobbleConfigs: [WobbleConfig] = [
        WobbleConfig(angle: Double.pi, ease: { pow($0 * 2, 2) / 4 }),
       // WobbleConfig(angle: Double.pi * 1.7, ease: { $0 }),
       // WobbleConfig(angle: Double.pi * 0.2, ease: { $0 }),
    ]

    public var vertexCount: Int {
        return max(60, Int(sqrt(blobState.radius)) * 2)
    }

    public func update(deltaTime: Double) {
        lifetime += deltaTime
        updateVertices()
    }

    override public func generateVertices() {
        var vertices = [DPoint2]()

        for i in 0..<vertexCount {
            let angle = 2 * Double.pi / Double(vertexCount) * Double(i)
            let direction = DVec2(cos(angle), sin(angle))
            let radialOffset = direction * blobState.radius
 
            let vertex = blobState.position + radialOffset
 
            vertices.append(vertex)
        }

        self.bounds = blobState.bounds

        self.vertices = vertices
    }

    public func updateVertices() {
        let linearProgress = lifetime.truncatingRemainder(dividingBy: 3) / 3
        let cyclicalProgress = abs(linearProgress - 0.5) * 2

        var updatedVertices: [DVec2] = []
        var max = DPoint2(-.infinity, -.infinity)
        var min = DPoint2(.infinity, .infinity)

        for i in 0..<vertices.count {
            let vertexAngle = 2 * Double.pi / Double(vertexCount) * Double(i)

            let direction = DVec2(cos(vertexAngle), sin(vertexAngle))
            
            let restingOffset = direction * blobState.radius

            let wobbleDisplacement = wobbleConfigs.reduce(into: 0.0) {
                let angleDisplacement = linearProgress * Double.pi * 2
                let displacedWobbleAngle = ($1.angle + angleDisplacement).truncatingRemainder(dividingBy: Double.pi * 2)
                var angleDistance = abs(displacedWobbleAngle - vertexAngle).truncatingRemainder(dividingBy: Double.pi * 2) 
                if angleDistance > Double.pi {
                    angleDistance = 2 * Double.pi - angleDistance
                }
                if angleDistance < Double.pi / 2 {
                    let angleProgress = angleDistance / Double.pi * 2
                    let accelerationFactor = blobState.acceleration.normalized().dot(direction)
                    $0 += cos(angleProgress * Double.pi / 2) * $1.ease(cyclicalProgress) * 4 * accelerationFactor // abs(cyclicalProgress - 0.5) * 2 * 4
                    // TODO: improve, finish wobble animation, maybe need afterwards smoothing algo
                }
            }

            let targetWobbleOffset = restingOffset + direction * wobbleDisplacement * cyclicalProgress

            let vertex = blobState.position + targetWobbleOffset

            updatedVertices.append(vertex)

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

        self.vertices = updatedVertices
        self.bounds = DRect(min: min, max: max)
    }
}