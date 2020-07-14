public struct Insets {
    public var top: Double
    public var right: Double
    public var bottom: Double
    public var left: Double

    public init(top: Double, right: Double, bottom: Double, left: Double) {
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
    }

    public init(t: Double, r: Double, b: Double, l: Double) {
        self.init(top: t, right: r, bottom: b, left: l)
    }

    public init(_ top: Double, _ right: Double, _ bottom: Double, _ left: Double) {
        self.init(top: top, right: right, bottom: bottom, left: left)
    }
}