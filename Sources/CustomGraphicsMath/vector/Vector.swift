import Foundation

public protocol Vector: Matrix {}

public extension Vector {
    var description: String {
        get {
            return "Vector \(rows) \(elements)"
        }
    }

    init(rows: Int) {
        self.init()
        self.rows = rows
    }

    init(rows: Int, elements: [Element]) {
        self.init()
        self.rows = rows
        for i in 0..<Swift.min(elements.count, self.elements.count) {
            self.elements[i] = elements[i]
        }
    }

    init(_ elements: [Element]) {
        self.init()
        self.elements = elements
        self.rows = elements.count
    }

    subscript(row: Int) -> Element {
        get {
            return elements[row]
        }

        set {
            elements[row] = newValue
        }
    }

    func clone() -> Self {
        return Self(elements)
    }

    func firstIndex(of element: Element) -> Int? {
        return elements.firstIndex(of: element)
    }

    /// TODO: maybe this function is not needed --> T might be a vector with different Row count than Self
    func asType <T: Vector> (_ castElement: (_ x: Element) -> T.Element) -> T {
        return T(rows: rows, elements: elements.map(castElement))
    }

    /*func to <T: Vector> (_ type: T.Type) -> T where T.Element: () -> Any {
        return type.init((elements.map(T.Element.init as! (Self.Element) -> Any)) as! [T.Element])
    } */

    func dot(_ otherVector: Self) -> Element {
        var result = Element.zero
        for i in 0..<count {
            result += self[i] * otherVector[i]
        }
        return result
    }

    static func - (lhs: Self, rhs: Self) -> Self {
        let rows = Swift.max(lhs.rows, rhs.rows)
        var resultVector = Self(rows: rows)
        for i in 0..<Swift.min(lhs.rows, rhs.rows) {
            resultVector[i] = lhs[i] - rhs[i]
        }
        return resultVector
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        let rows = Swift.max(lhs.rows, rhs.rows)
        var resultVector = Self(rows: rows)
        for i in 0..<Swift.min(lhs.rows, rhs.rows) {
            resultVector[i] = lhs[i] + rhs[i]
        }
        return resultVector
    }

    static func * (lhs: Self, rhs: Element) -> Self {
        var result = Self(rows: lhs.rows)
        for i in 0..<lhs.rows {
            result[i] = lhs[i] * rhs
        }
        return result
    }

    static func * (lhs: Element, rhs: Self) -> Self {
        rhs * lhs
    }

    static func += (lhs: inout Self, rhs: Self) {
        for i in 0..<Swift.min(lhs.rows, rhs.rows) {
            lhs[i] += rhs[i]
        }
    }

    static func -= (lhs: inout Self, rhs: Self) {
        for i in 0..<Swift.min(lhs.rows, rhs.rows) {
            lhs[i] -= rhs[i]
        }
    }

    static func *= (lhs: inout Self, rhs: Element) {
        for i in 0..<lhs.count {
            lhs[i] *= rhs
        }
    }
}

/// - Returns: The component-wise min of two given vectors.
public func min<V: Vector>(_ vec1: V, _ vec2: V) -> V where V.Element: Comparable {
    V.init((0..<vec1.count).map { vec1[$0] < vec2[$0] ? vec1[$0] : vec2[$0] })
}

/// - Returns: The component-wise max of two given vectors.
public func max<V: Vector>(_ vec1: V, _ vec2: V) -> V where V.Element: Comparable {
    V.init((0..<vec1.count).map { vec1[$0] > vec2[$0] ? vec1[$0] : vec2[$0] })
}

 /*   init<Other: ConvertibleScalar>(_ elements: [Other]) where Self.Element: ConvertibleScalar, Self.Element.OOther.OtherScalar == Self. {
        self.init()
        self.elements = elements.map(Self.Element.init)
    }*/
public extension Vector where Element: BinaryInteger {
    // TODO: maybe put those two into matrix
    init<Other: Vector>(_ other: Other) where Other.Element: BinaryInteger {
        self.init(other.map({ Element.init($0) }))
    }

    init<Other: Vector>(_ other: Other) where Other.Element: BinaryFloatingPoint {
        self.init(other.map({ Element.init($0) }))
    }
}

public extension Vector where Element: FloatingPoint {
    @available(*, deprecated, message: "Use .magnitude instead.")
    var length: Element {
        get {
            var sum: Element = 0
            for element in self {
                sum += element * element
            }
            return sqrt(sum)
        }
    }
    var magnitude: Element {
        get {
            length
        }
    }

    // TODO: maybe put those two into matrix
    init<Other: Vector>(_ other: Other) where Other.Element: BinaryFloatingPoint, Self.Element: BinaryFloatingPoint {
        self.init(other.map(Element.init))
    }

    init<Other: Vector>(_ other: Other) where Other.Element: BinaryInteger {
        self.init(other.map(Element.init))
    }

    func normalized() -> Self {
        var normalized = Self(rows: rows)
        if length == 0 {
            return normalized
        }
        for i in 0..<rows {
            normalized[i] = self[i] / length
        }
        return normalized
    }

    func rounded() -> Self {
        var result = Self(rows: rows)
        for i in 0..<count {
            result[i] = self[i].rounded()
        }
        return result
    }

    func rounded(_ rule: FloatingPointRoundingRule) -> Self {
        var result = Self(rows: rows)
        for i in 0..<count {
            result[i] = self[i].rounded(rule)
        }
        return result
    }

    static func / (lhs: Self, rhs: Element) -> Self {
        var result = Self(rows: lhs.rows)
        for i in 0..<lhs.count {
            result[i] = lhs[i] / rhs
        }
        return result
    }

    static func / (lhs: Self, rhs: Self) -> Self {
        var result = lhs.clone()
        for i in 0..<result.count {
            result[i] /= rhs[i]
        }
        return result
    }

    /*static func / <T: Vector> (lhs: Self, rhs: T) -> Self where T.Element: FloatingPoint , T.Element == Self.Element {
        var result = lhs.clone()
        for i in 0..<lhs.count {
            result.elements[i] /= rhs.elements[i]
        }
        return result
    }*/
}

public struct AnyVector<E: Numeric & Hashable>: Vector {
    public typealias Element = E
    public var rows: Int
    public var cols: Int
    public var elements: [Element]
    
    public init() {
        self.rows = 0
        self.cols = 1
        self.elements = [Element](repeating: 0, count: 3)
    }
}

public protocol Vector2: Vector {
    var x: Element { get set }
    var y: Element { get set }
}

public extension Vector2 {
    var x: Element {
        get {
            return elements[0]
        }
        set {
            elements[0] = newValue
        }
    }
    var y: Element {
        get {
            return elements[1]
        }
        set {
            elements[1] = newValue
        }
    }
 
    init(_ elements: [Element]) {
        self.init()
        self.elements = elements
    }

    init(_ x: Element, _ y: Element) {
        self.init([x, y])
    }

    func cross(_ other: Self) -> Element {
        return self.x * other.y - self.y * other.x
    }
}


public extension Vector2 where Element: BinaryFloatingPoint, Element.RawSignificand: FixedWidthInteger {
    static var infinity: Self {
        Self(Element.infinity, Element.infinity)
    }
    
    static func random(in bounds: Rect<Element>) -> Self {
        self.init(Element.random(in: bounds.min.x...bounds.max.x), Element.random(in: bounds.min.y...bounds.max.y))
    }
}

public struct AnyVector2<E: Numeric & Hashable>: Vector2 {
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
public typealias DVec2 = AnyVector2<Double>
public typealias FVec2 = AnyVector2<Float>
public typealias IVec2 = AnyVector2<Int>

public protocol Vector3: Vector {

}

public extension Vector3 {
    public init(_ elements: [Element]) {
        self.init()
        self.elements = elements
    }

    public init(_ x: Element, _ y: Element, _ z: Element) {
        self.init()
        self.elements = [x, y, z]
    }

    public func cross(_ rhs: Self) -> Self {
        let x = self[1] * rhs[2] - self[2] * rhs[1]
        let y = self[2] * rhs[0] - self[0] * rhs[2]
        let z = self[0] * rhs[1] - self[1] * rhs[0]
        return Self([
            x,
            y,
            z
        ])
    }

    public var x: Element {
        get {
            return elements[0]
        }
        set {
            elements[0] = newValue
        }
    }

    public var y: Element {
        get {
            return elements[1]
        }
        set {
            elements[1] = newValue
        }
    }

    public var z: Element {
        get {
            return elements[2]
        }
        set {
            elements[2] = newValue
        }
    }
}

public extension Vector3 where Element: FloatingPointGenericMath {
    /// returns 0 to pi (positive only)
    func absAngle(to otherVector: Self) -> Element {
        let angle = acos(self.normalized().dot(otherVector.normalized()))
        return angle
    }
}

public struct AnyVector3<E: Numeric & Hashable>: Vector3 {
    public typealias Element = E
    public var rows: Int
    public var cols: Int
    public var elements: [Element]

    public init() {
        self.rows = 3
        self.cols = 1
        self.elements = [Element](repeating: 0, count: 3)
    }
}

public protocol Vector4: Vector3 {
    var w: Element { get set }
}

public struct AnyVector4<E: Numeric & Hashable>: Vector {
    public typealias Element = E
    public var rows: Int
    public var cols: Int
    public var elements: [Element]
    public var x: Element {
        get {
            return elements[0]
        }
        set {
            elements[0] = newValue
        }
    }
    public var y: Element {
        get {
            return elements[1]
        }
        set {
            elements[1] = newValue
        }
    }
    public var z: Element {
        get {
            return elements[2]
        }
        set {
            elements[2] = newValue
        }
    }
    public var w: Element {
        get {
            return elements[3]
        }
        set {
            elements[3] = newValue
        }
    }

    public init() {
        self.rows = 4
        self.cols = 1
        self.elements = [Element](repeating: 0, count: 4)
    }

    public init(_ elements: [Element]) {
        self.rows = 4
        self.cols = 1
        self.elements = elements
    }

    public static func * <M: Matrix4> (lhs: M, rhs: Self) -> Self where M.Element == Self.Element {
        let result = try! lhs.matmul(rhs)
        return Self(result.elements)
    }
}