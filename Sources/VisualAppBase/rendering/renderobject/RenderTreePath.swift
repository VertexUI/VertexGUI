public struct RenderTreePath: Sequence {
    public var segments: [Int]

    public var count: Int {
        return segments.count
    }

    public var last: Int? {
        return segments.last
    }

    public init(_ segments: [Int] = []) {
        self.segments = segments
    }

    public subscript(index: Int) -> Int {
        get {
            segments[index]
        }
        set {
            segments[index] = newValue
        }
    }

    public func makeIterator() -> IndexingIterator<[Int]> {
        return segments.makeIterator()
    }

    public func dropFirst(_ k: Int = 1) -> Self {
        return Self(Array(segments.dropFirst(k)))
    }

    public func dropLast(_ k: Int = 1) -> Self {
        return Self(Array(segments.dropLast(k)))
    }

    public static func / (lhs: Self, rhs: Int) -> Self {
        return Self(lhs.segments + [rhs])
    }

    public static func + (lhs: Self, rhs: Int) -> Self {
        if lhs.count == 0 {
            return lhs
        }
        return Self(lhs.segments[0..<lhs.count - 1] + [lhs.last! + rhs])
    }

    @discardableResult public mutating func removeLast() -> Int {
        return segments.removeLast()
    }
}

