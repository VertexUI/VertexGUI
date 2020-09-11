public protocol Plane {
    associatedtype VectorProtocol: Vector3Protocol
    var point: VectorProtocol { get set }
    var normal: VectorProtocol { get set }

    init()
}

public extension Plane where VectorProtocol.Element: FloatingPoint {
    var elevation: VectorProtocol.Element {
        get {
            return point.dot(normal)
        }
    }

    public init(point: VectorProtocol, normal: VectorProtocol) {
        self.init()
        self.point = point
        self.normal = normal.normalized()
    }
}

public struct AnyPlane<E: Numeric & Hashable>: Plane {
    public typealias VectorProtocol = Vector3<E>
    public var point: Vector3<E>
    public var normal: Vector3<E>

    public init() {
        self.point = Vector3<E>()
        self.normal = Vector3<E>()
    }
}