public struct RenderTreePath {
    public var segments: [Int]

    public var count: Int {
        return segments.count
    }

    public init(_ segments: [Int]) {
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
}

