//

//

import Foundation

public typealias Size<E: Numeric & Hashable> = Vector<E>

public typealias Size3<E: Numeric & Hashable> = Vector3<E>

public protocol Size2Protocol: Vector2Protocol {

}

public extension Size2Protocol {

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

public struct Size2<E: Numeric & Hashable>: Size2Protocol {

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

public typealias DSize2 = Size2<Double>

public typealias ISize2 = Size2<Int>

public typealias DSize3 = Size3<Double>

public typealias ISize3 = Size3<Int>