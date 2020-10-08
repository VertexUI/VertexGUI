public struct TreePath: Sequence, Comparable, Hashable, Equatable, CustomDebugStringConvertible {
    public var segments: [Int]

    public var count: Int {
        return segments.count
    }

    public var last: Int? {
        return segments.last
    }

    public var debugDescription: String {
        "TreePath { \(segments.map(String.init).joined(separator: ", ")) }"
    }

    public init(_ segments: [Int] = []) {
        self.segments = segments
    }

    public init(_ segments: Int...) {
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

    @discardableResult public mutating func popLast() -> Int? {
        segments.popLast()
    }

    /*@discardableResult public mutating func removeLast() -> Int {
        return segments.removeLast()
    }*/

    public static func / (lhs: Self, rhs: Int) -> Self {
        return Self(lhs.segments + [rhs])
    }

    public static func + (lhs: Self, rhs: Int) -> Self {
        if lhs.count == 0 {
            return lhs
        }
        return Self(lhs.segments[0..<lhs.count - 1] + [lhs.last! + rhs])
    }

    /// - Returns true if any component of lhs is smaller than rhs or lhs is shorter than rhs
    public static func < (lhs: Self, rhs: Self) -> Bool {
        let compareCount = Swift.min(lhs.count, rhs.count)
        for i in 0..<compareCount {
            if lhs[i] < rhs[i] {
                return true
            } else if lhs[i] > rhs[i] {
                return false
            }
        }
        return lhs.count < rhs.count
    }
    
    /// - Returns true if any component of lhs is bigger than rhs or lhs is longer than rhs
    public static func > (lhs: Self, rhs: Self) -> Bool {
        let compareCount = Swift.min(lhs.count, rhs.count)
        for i in 0..<compareCount {
            if lhs[i] > rhs[i] {
                return true
            } else if lhs[i] < rhs[i] {
                return false
            }
        }
        return lhs.count > rhs.count
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.segments == rhs.segments
    }
}

