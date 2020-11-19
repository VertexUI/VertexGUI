import Foundation

/// Axis aligned rect in 2 coordinate space.
public struct Rect<E: BinaryFloatingPoint>: Equatable, Hashable {
    public var min: Vector2<E>
    public var max: Vector2<E> {
        get {
            min + Vector2<E>(size)
        }
        /*set {
            size = Size2<E>(max - min)
        }*/
    }

    public var size: Size2<E>

    
    public var width: E {
        get {
            size.width
        }
        set {
            size.width = newValue
        }
    }

    public var height: E {
        get {
            size.height
        }
        set {
            size.height = newValue
        }
    }
    
    public var center: Vector2<E> {
        min + Vector2(size) / 2
    }

    public var area: E {
        size.width * size.height
    }

    // TODO: maybe implement as protocol as well and don't use Vector2<E> but Vector2Protocol where Vector2Protocol.E == E?
    public init(min: Vector2<E>, size: Size2<E>) {
        self.min = min
        self.size = size
    }

    public init(max: Vector2<E>, size: Size2<E>) {
        self.min = max - Vector2(size)
        self.size = size
    }

    public init(min: Vector2<E>, max: Vector2<E>/*, layout: VectorLayout2<Vector2<E>> = .bottomLeftToTopRight*/) {
        self.min = min
        self.size = Size2(max - min)
    }

    public init(center: Vector2<E>, size: Size2<E>) {
        self.init(min: Vector2<E>(center.x - size.width / 2, center.y - size.height / 2), size: size)
    }

    public var vertices: [Vector2<E>] {
        [
            min,
            min + Vector2(size.x, 0),
            min + Vector2(0, size.y),
            max
        ]
    }

    // TODO: might add set operations as well
    /*public var topLeft: Vector2<E> {
        get {
            Vector2<E>()
        }
    }

    // TODO: these calculations need to be redone
    public var bottomLeft: Vector2<E> {
        get {
            return Vector2<E>(topLeft.x, topLeft.y + size.height)
        }
    }

    public var bottomRight: Vector2<E> {
        get {
            return Vector2<E>(topLeft.x + size.width, topLeft.y + size.height)
        }
    }

    public var center: Vector2<E> {
        get {
            return Vector2<E>(topLeft.x + size.width / 2, topLeft.y + size.height / 2)
        }
    }*/

    public func contains(point: Vector2<E>) -> Bool {
        point.x >= min.x && point.x <= max.x && point.y >= min.y && point.y <= max.y
    }

    public func intersects(_ otherRect: Rect<E>) -> Bool {
        for ownVertex in self.vertices {
            if otherRect.contains(point: ownVertex) {
                return true
            }
        }

        for otherVertex in otherRect.vertices {
            if contains(point: otherVertex) {
                return true
            }
        }           

        return false
    }

    public mutating func translate(_ amount: Vector2<E>) {
        self.min += amount
    }

    public func translated(_ amount: Vector2<E>) -> Self {
        var result = self
        result.translate(amount)
        return result
    }
}

/// An axis aligned Rect in 2 coordinate space.
/// - SeeAlso: Rect
public typealias DRect = Rect<Double>