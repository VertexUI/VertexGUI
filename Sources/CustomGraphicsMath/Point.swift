//

//

import Foundation

public typealias PointProtocol = VectorProtocol
public typealias Point2Protocol = Vector2Protocol
public typealias Point3Protocol = Vector3Protocol
public typealias Point4Protocol = Vector4Protocol

public typealias Point2<E: Numeric & Hashable> = Vector2<E>

public typealias Point3<E: Numeric & Hashable> = Vector3<E>

public typealias DPoint2 = Point2<Double>
public typealias IPoint2 = Point2<Int>

public typealias DPoint3 = Point3<Double>

/*
public struct Point: Equatable {
    public var x: Double
    public var y: Double
    public var length: Double {
        get {
            return sqrt(pow(x, 2) + pow(y, 2))
        }
    }
}

public extension Point {
    public init(_ x: Double, _ y: Double) {
        self.init(x: x, y: y)
    }

    static func + (lhs: Point, rhs: Point) -> Point {
        return Point(lhs.x + rhs.x, lhs.y + rhs.y)
    }

    static func - (lhs: Point, rhs: Point) -> Point {
        return Point(lhs.x - rhs.x, lhs.y - rhs.y)
    }
}*/