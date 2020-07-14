//
// Created by adrian on 18.04.20.
//

import Foundation

/// axis aligned rect in 2 coordinate space
// TODO: maybe this belongs into UIPackage?
public struct Rect<E: FloatingPoint>: Equatable {
    public enum Edge: CaseIterable {
        case Top, Right, Bottom, Left
    }

    public var topLeft: AnyVector2<E>
    public var size: AnySize2<E>

    public init(topLeft: AnyVector2<E>, size: AnySize2<E>) {
        self.topLeft = topLeft
        self.size = size
    }

    public init(topLeft: AnyVector2<E>, bottomRight: AnyVector2<E>) {
        self.init(topLeft: topLeft, size: AnySize2<E>(bottomRight.x - topLeft.x, bottomRight.y - topLeft.y))
    }

    public init(center: AnyVector2<E>, size: AnySize2<E>) {
        self.init(topLeft: AnyVector2<E>(center.x - size.width / 2, center.y - size.height / 2), size: size)
    }

    public init(x: E, y: E, width: E, height: E) {
        self.init(topLeft: AnyVector2<E>(x, y), size: AnySize2<E>(width, height))
    } 

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
    }

    public func contains(point: AnyVector2<E>) -> Bool {
        return point.x >= topLeft.x && point.x <= bottomRight.x && point.y >= topLeft.y && point.y <= bottomRight.y
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