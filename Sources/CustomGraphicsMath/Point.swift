//

//

import Foundation

public typealias Point = Vector
public typealias Point2 = Vector2
public typealias Point3 = Vector3
public typealias Point4 = Vector4

public typealias AnyPoint2<E: Numeric> = AnyVector2<E>
public typealias DPoint2 = AnyPoint2<Double>

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