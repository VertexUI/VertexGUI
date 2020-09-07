import Foundation

public protocol Matrix: Sequence, Equatable, CustomStringConvertible, Hashable {
    associatedtype Element: Numeric

    var rows: Int { get set }
    var cols: Int { get set }
    var elements: [Element] { get set }
    var count: Int { get }
    static var zero: Self { get }

    init()
    //init(rows: Int, cols: Int)

    subscript(row: Int, col: Int) -> Element { get set }

    func clone() -> Self
}

public struct MatrixSizeError: Error {}

public extension Matrix {
    var description: String {
        get {
            return "Matrix r:\(rows) x c:\(cols) \(elements)"
        }
    }

    var count: Int {
        get {
            return rows * cols
        }
    }

    static var zero: Self {
        get {
            Self()
        }
    }

    subscript(row: Int, col: Int) -> Element { 
        get {
            return elements[row * self.cols + col]
        }

        set {
            elements[row * self.cols + col] = newValue
        }
    }

    func makeIterator() -> Array<Element>.Iterator {
        return elements.makeIterator()
    }

    // TODO: there might be a more efficient way to transpose
    func transposed() -> Self {
        var matrix = clone() // TODO: maybe have some clone function that does not clone elements
        for rIndex in 0..<self.rows {
            for cIndex in 0..<self.cols {
                matrix[cIndex, rIndex] = self[rIndex, cIndex]
            }
        }
        return matrix
    }

    func firstIndex(of element: Element) -> (Int, Int)? {
        for row in 0..<rows {
            for col in 0..<cols {
                if self[row, col] == element {
                    return (row, col)
                }
            }
        }
        return nil
    }

    mutating func add_<T: Matrix>(_ matrix2: T) throws where T.Element == Self.Element {
        if !(matrix2.rows == rows && matrix2.cols == cols) {
            throw MatrixSizeError()
        }

        for rIndex in 0..<self.rows {
            for cIndex in 0..<self.cols {
                self[rIndex, cIndex] += matrix2[rIndex, cIndex]
            }
        }
    }

    func matmul<T: Matrix>(_ other: T) throws -> AnyMatrix<Element> where T.Element == Element {
        if (self.cols != other.rows) {
            throw MatrixMultiplicationError()
        }
        var result = AnyMatrix<Element>(rows: self.rows, cols: other.cols)
        for rIndex in 0..<self.rows {
            for cIndex in 0..<other.cols {
                var element = Self.Element.init(exactly: 0)!
                for iIndex in 0..<self.cols {
                    element += self[rIndex, iIndex] * other[iIndex, cIndex]
                }
                result[rIndex, cIndex] = element
            }
        }
        return result
    }

    // TODO: need to add throws if dimensions don't match
    static func + (lhs: Self, rhs: Element) -> Self {
        var result = lhs.clone()
        for i in 0..<lhs.count {
            result.elements[i] += rhs
        }
        return result
    }

    /*func matmul<T: Vector>(_ other: T) throws -> Self {

    }*/
}

public extension Matrix where Element: FloatingPoint {
    static func /= (lhs: inout Self, rhs: Element) {
        for i in 0..<lhs.count {
            lhs.elements[i] /= rhs
        }
    }

    /// element wise division
    // TODO: divide only the overlapping elements
    static func / (lhs: Self, rhs: Self) -> Self {
        var result = lhs.clone()
        for i in 0..<lhs.count {
            result.elements[i] /= rhs.elements[i]
        }
        return result
    }

    /// element wise multiplication
    // TODO: multiply only the overlapping elements
    static func * <Other: Matrix> (lhs: Self, rhs: Other) -> Self where Other.Element == Element {
        var result = lhs.clone()
        for i in 0..<result.count {
            result.elements[i] *= rhs.elements[i]
        }
        return result
    }

    static prefix func - (mat: Self) -> Self {
        var result = mat.clone()
        for i in 0..<mat.count {
            result.elements[i] = -result.elements[i]
        }
        return result
    }
}

public extension Matrix where Element: Comparable {
    func max() -> Element? {
        return elements.max()
    }
    /*func oneHotted() -> Self {
        let maxValue = elements.max()
        let index = elements.firstIndex(of: maxValue!)!
        var result = Self()
        result.elements[index] = 1
        return result
    }*/
}

public extension Matrix where Element: Comparable, Element: SignedNumeric {
    func abs() -> Self {
        var result = Self()
        for i in 0..<count {
            result.elements[i] = Swift.abs(self.elements[i])
        }
        return result
    }
}

public struct MatrixMultiplicationError: Error {}

// TODO: maybe add more matrix math

/*public func * <T1: Matrix, T2: Matrix>(lhs: T1, rhs: T2) throws -> AnyMatrix<T1.Element> where T1.Element == T2.Element {
    return try lhs.matmul(rhs)
}*/



/*
THIS IMPLEMENTATION IS LIKELY NOT CORRECT / does not do what *= is expected to do
public func *= <T: Matrix>(lhs: inout T, rhs: T) throws -> AnyMatrix {
    return try lhs * rhs
}*/

public struct AnyMatrix<E: Numeric & Hashable>: Matrix {
    public typealias Element = E
    public var rows: Int
    public var cols: Int
    public var elements: [E]

    public init() {
        rows = 0
        cols = 0
        elements = [E]()
    }

    public init(rows: Int, cols: Int) {
        self.init()
        self.rows = rows
        self.cols = cols
        self.elements = [Element](repeating: Element.zero, count: count)
    }

    public init(rows: Int, cols: Int, elements: [Element]) {
        self.init()
        self.rows = rows
        self.cols = cols
        self.elements = elements
    }
    
    // TODO: might check for correct size of elements
    public init(_ elements: [Element]) {
        self.init()
        self.elements = elements
    }

    public func clone() -> Self {
        return Self(rows: rows, cols: cols, elements: elements)
    }
}

public protocol Matrix4: Matrix {}

public extension Matrix4 {
    static var identity: Self {
        get {
            return Self([
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                0, 0, 0, 1
            ])
        }
    }
 
    init(_ elements: [Element]) {
        self.init()
        self.elements = elements
    }

    func clone() -> Self {
        return Self(elements)
    }

func matmul(_ other: Self) throws -> Self {
        if (self.cols != other.rows) {
            throw MatrixMultiplicationError()
        }
        var result = Self()
        for rIndex in 0..<self.rows {
            for cIndex in 0..<other.cols {
                var element = Self.Element.init(exactly: 0)!
                for iIndex in 0..<self.cols {
                    element += self[rIndex, iIndex] * other[iIndex, cIndex]
                }
                result[rIndex, cIndex] = element
            }
        }
        return result
    }
}

public extension Matrix4 where Element: FloatingPointGenericMath {
    static func transformation(translation: AnyVector3<Element>, scaling: AnyVector3<Element>, rotationAxis: AnyVector3<Element>, rotationAngle: Element) -> Self {
        let ar = rotationAngle / Element(180) * Element.pi
        let rc = cos(ar)
        let rc1 = 1 - rc
        let rs = sin(ar)
        let ra = rotationAxis
        let r1c1 = scaling[0] * (rc + pow(ra[0], 2) * rc1)
        let r1c2 = ra[0] * ra[1] * rc1
        let r1c3 = ra[0] * ra[2] * rc1 + ra[1] * rs
        let r1c4 = translation[0]
        let r2c1 = ra[1] * ra[0] * rc1 + ra[2] * rs
        let r2c2 = scaling[1] * (rc + pow(ra[1], 2) * rc1)
        let r2c3 = ra[1] * ra[2] * rc1 - ra[0] * rs
        let r2c4 = translation[1]
        let r3c1 = ra[2] * ra[0] * rc1 - ra[1] * rs
        let r3c2 = ra[2] * ra[1] * rc1 + ra[0] * rs
        let r3c3 = scaling[2] * (rc + pow(ra[2], 2) * rc1)
        let r3c4 = translation[2]
        return Self([
            r1c1, r1c2, r1c3, r1c4,
            r2c1, r2c2, r2c3, r2c4,
            r3c1, r3c2, r3c3, r3c4,
            0, 0, 0, 1
        ])
    }

    // TODO: the following functions might be specific to openGL, maybe put those in the GLGraphicsMath package
    static func viewTransformation<V: Vector3>(up: V, right: V, front: V, translation: V) -> Self where V.Element == Self.Element {
        return try! Self([
            right.x, right.y, right.z, 0,
            up.x, up.y, up.z, 0,
            front.x, front.y, front.z, 0,
            0, 0, 0, 1
        ]).matmul(Self([
            1, 0, 0, translation.x,
            0, 1, 0, translation.y,
            0 , 0, 1, translation.z,
            0, 0, 0, 1
        ]))
    }

    /// - Parameter fov: field of view angle in degrees
    static func perspectiveProjection(aspectRatio: Element, near: Element, far: Element, fov: Element) -> Self {
        let fovRad = fov / Element(180) * Element.pi
        let r1c1 = 1 / (aspectRatio * tan(fovRad / 2))
        let r2c2 = Element(1) / tan(fovRad / Element(2))
        let r3c3 = -(far + near) / (far - near) 
        let r3c4 = -(Element(2) * far * near) / (far - near)
        return Self([
            r1c1, Element.zero, Element.zero, Element.zero,
            Element.zero, r2c2, Element.zero, Element.zero,
            Element.zero, Element.zero, r3c3, r3c4,
            Element.zero, Element.zero, Element(-1), Element.zero
        ])
    }

    static func orthographicProjection(top: Element, right: Element, bottom: Element, left: Element, near: Element, far: Element) -> Self {
        var r1c1 = Element(2) / (right - left)
        var r1c4 = -(right + left) / (right - left)
        var r2c2 = Element(2) / (top - bottom)
        var r2c4 = -(top + bottom) / (top - bottom)
        var r3c3 = Element(-2) / (far - near)
        var r3c4 = -(far + near) / (far - near)
        return Self([
            r1c1, 0, 0, r1c4,
            0, r2c2, 0, r2c4,
            0, 0, r3c3, r3c4,
            0, 0, 0, 1
        ])
    }
}

public struct AnyMatrix4<E: Numeric & Hashable>: Matrix4 {
    public typealias Element = E
    public var rows: Int
    public var cols: Int
    public var elements: [E]

    public init() {
        rows = 4
        cols = 4
        elements = [E](repeating: E.zero, count: rows * cols)
    }

    /*public func matmul(_ other: AnyMatrix4<E>) -> AnyMatrix4<E> {
        return try! AnyMatrix4(self.matmul(other).elements)
    }*/
}

// TODO: might replace this or remove this / current function of this is to simply remove throws
public func * <E: Numeric>(lhs: AnyMatrix4<E>, rhs: AnyMatrix4<E>) -> AnyMatrix4<E> {
    return try! lhs.matmul(rhs)
}