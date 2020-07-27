//

//

import Foundation

// TODO: maybe instead of Vector, use MultiElementMath protocol or something like that
// TODO: maybe remove the name AnySize2<Float> as well and just use Vectors everywhere?
public typealias AnySize<E: Numeric & Hashable> = AnyVector<E>
//public typealias AnySize2<E: Numeric> = AnyVector2<E>
public typealias AnySize3<E: Numeric & Hashable> = AnyVector3<E>

public protocol Size2: Vector2 {

}

public extension Size2 {
    var width: Element {
        get {
            return x
        }
        set {
            x = newValue
        }
    }

    var height: Element {
        get {
            return y
        }
        set {
            y = newValue
        }
    }
}

public struct AnySize2<E: Numeric & Hashable>: Size2 {
    public typealias Element = E
    public var rows: Int
    public var cols: Int
    public var elements: [Element]

    public init() {
        self.rows = 2
        self.cols = 1
        self.elements = [Element](repeating: 0, count: 2)
    }
}

public typealias DSize2 = AnySize2<Double>
public typealias ISize2 = AnySize2<Int>

/*

public struct Size<E: Numeric>: Equatable {
    public var width: E
    public var height: E

    public init(width: E, height: E) {
        self.width = width
        self.height = height
    }

    public init(_ width: E, _ height: E) {
        self.width = width
        self.height = height
    }

    public static var zero = Self(E.zero, E.zero)
}*/