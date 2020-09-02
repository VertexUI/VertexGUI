import Foundation

/// Axis aligned rect in 2 coordinate space.
public struct Rect<E: BinaryFloatingPoint>: Equatable, Hashable {

    public var min: AnyVector2<E>

    public var max: AnyVector2<E> {

        get {

            min + AnyVector2<E>(size)
        }
        /*set {
            size = AnySize2<E>(max - min)
        }*/
    }

    public var size: AnySize2<E>/* {
        get {
            AnySize2(max - min)
        }
        set {
            max = min + AnyVector2(newValue)
        }
    }*/
    
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
    
    public var center: AnyVector2<E> {

        min + AnyVector2(size) / 2
    }

    public var area: E {

        size.width * size.height
    }

    // TODO: maybe implement as protocol as well and don't use AnyVector2<E> but Vector2 where Vector2.E == E?
    public init(min: AnyVector2<E>, size: AnySize2<E>) {

        self.min = min

        self.size = size
    }

    public init(min: AnyVector2<E>, max: AnyVector2<E>/*, layout: VectorLayout2<AnyVector2<E>> = .bottomLeftToTopRight*/) {

        self.min = min

        self.size = AnySize2(max - min)
    }

    public init(center: AnyVector2<E>, size: AnySize2<E>) {

        self.init(min: AnyVector2<E>(center.x - size.width / 2, center.y - size.height / 2), size: size)
    }

    public var vertices: [AnyVector2<E>] {

        [
            min,

            min + AnyVector2(size.x, 0),

            min + AnyVector2(0, size.y),
            
            max
        ]
    }

    // TODO: might add set operations as well
    /*public var topLeft: AnyVector2<E> {
        get {
            AnyVector2<E>()
        }
    }

    // TODO: these calculations need to be redone
    public var bottomLeft: AnyVector2<E> {
        get {
            return AnyVector2<E>(topLeft.x, topLeft.y + size.height)
        }
    }

    public var bottomRight: AnyVector2<E> {
        get {
            return AnyVector2<E>(topLeft.x + size.width, topLeft.y + size.height)
        }
    }

    public var center: AnyVector2<E> {
        get {
            return AnyVector2<E>(topLeft.x + size.width / 2, topLeft.y + size.height / 2)
        }
    }*/

    public func contains(point: AnyVector2<E>) -> Bool {

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

    public mutating func translate(_ amount: AnyVector2<E>) {

        self.min += amount
    }

    public func translated(_ amount: AnyVector2<E>) -> Self {

        var result = self

        result.translate(amount)

        return result
    }
}

/// An axis aligned Rect in 2 coordinate space.
/// - SeeAlso: Rect
public typealias DRect = Rect<Double>