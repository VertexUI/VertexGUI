//

//

import Foundation

/// axis aligned rect in 2 coordinate space
// TODO: maybe this belongs into UIPackage?
public struct Rect<E: BinaryFloatingPoint>: Equatable, Hashable {
    /*public enum Edge: CaseIterable {
        case Top, Right, Bottom, Left
    }*/

    //@available(*, deprecated, message: "Use min, max, orientations depend on setup of coordinate system.")
    //public var topLeft: AnyVector2<E>
    public var min: AnyVector2<E>
    public var max: AnyVector2<E>
    public var size: AnySize2<E> {
        get {
            AnySize2(max - min)
        }
        set {
            max = min + AnyVector2(newValue)
        }
    }
    public var center: AnyVector2<E> {
        min + AnyVector2(size) / 2
    }
    //public var layout: VectorLayout2<AnyVector2<E>>

    // TODO: maybe implement as protocol as well and don't use AnyVector2<E> but Vector2 where Vector2.E == E?
    public init(min: AnyVector2<E>, size: AnySize2<E>) {
        self.min = min
        self.max = min + AnyVector2(size)
    }

    /*public init(topLeft: AnyVector2<E>, bottomRight: AnyVector2<E>) {
        self.init(topLeft: topLeft, size: AnySize2<E>(bottomRight.x - topLeft.x, bottomRight.y - topLeft.y))
    }*/

    public init(min: AnyVector2<E>, max: AnyVector2<E>/*, layout: VectorLayout2<AnyVector2<E>> = .bottomLeftToTopRight*/) {
        self.min = min
        self.max = max
        //self.size = AnySize2(max - min)
        //self.topLeft = min
        //self.layout = layout
    }

    public init(center: AnyVector2<E>, size: AnySize2<E>) {
        self.init(min: AnyVector2<E>(center.x - size.width / 2, center.y - size.height / 2), size: size)
    }
    /*
    public init(x: E, y: E, width: E, height: E) {
        self.init(topLeft: AnyVector2<E>(x, y), size: AnySize2<E>(width, height))
    }*/

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
        return point.x >= min.x && point.x <= max.x && point.y >= min.y && point.y <= max.y
    }

    /*public var translation: Vector

    public init(_ translation: Vector) {
        self.translation = translation
    }*/

    /*public enum Geometry {
        public static func edgeVertices<Vector: Vector2>(_ translation: Vector) -> [Edge: (Vector, Vector)] {
            return [
                .Top: (translation, translation + Vector(1, 0)),
                .Right: (translation + Vector(1, 0), translation + Vector(1, 1)),
                .Bottom: (translation + Vector(1, 1), translation + Vector(0, 1)),
                .Left: (translation, translation + Vector(0, 1))
            ]
        }
    }*/
}

public typealias DRect = Rect<Double>