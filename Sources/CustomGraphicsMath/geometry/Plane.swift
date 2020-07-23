public protocol Plane {
    associatedtype Vector: Vector3
    var point: Vector { get set }
    var normal: Vector { get set }

    init()
}

public extension Plane where Vector.Element: FloatingPoint {
    var elevation: Vector.Element {
        get {
            return point.dot(normal)
        }
    }

    public init(point: Vector, normal: Vector) {
        self.init()
        self.point = point
        self.normal = normal.normalized()
    }
}

public struct AnyPlane<E: Numeric & Hashable>: Plane {
    public typealias Vector = AnyVector3<E>
    public var point: AnyVector3<E>
    public var normal: AnyVector3<E>

    public init() {
        self.point = AnyVector3<E>()
        self.normal = AnyVector3<E>()
    }
}