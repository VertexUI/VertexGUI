import GfxMath

public struct Insets: Equatable {
    public var top: Double
    public var right: Double
    public var bottom: Double
    public var left: Double
    public var aggregateSize: DSize2 {
        DSize2(right + left, top + bottom)
    }

    public init(top: Double = 0, right: Double = 0, bottom: Double = 0, left: Double = 0) {
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
    }

    public init(_ top: Double, _ right: Double, _ bottom: Double, _ left: Double) {
        self.init(top: top, right: right, bottom: bottom, left: left)
    }

    public init(all value: Double) {
        self.init(top: value, right: value, bottom: value, left: value)
    }

    public init(_ value: Double) {
        self.init(top: value, right: value, bottom: value, left: value)
    }

    public static var zero = Insets(all: 0)
}