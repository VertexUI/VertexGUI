import CustomGraphicsMath
import Foundation

public class BlobDrawable {
    public let id: UInt
    public var position: DPoint2
    public var radius: Double
    public var vertexCount: Int {
        return Int(radius * 2)
    }
    public internal(set) var vertices: [DPoint2] = []
    public internal(set) var bounds: DRect

    public internal(set) var lifetime: Double = 0

    public var consumed: Bool = false


    public init(id: UInt, position: DPoint2, radius: Double) {
        self.id = id
        self.position = position
        self.radius = radius
        self.bounds = DRect(center: position, size: DSize2.zero)
    }

    public func update(deltaTime: Double) {
        lifetime += deltaTime
        updateVertices()
    }

    public func updateVertices() {
        fatalError("updateVertices() not implemented.")
    }
}