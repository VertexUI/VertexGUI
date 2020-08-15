// TODO: maybe this belongs to CustomGraphicsMath
public struct CornerRadii {
    public var topLeft: Double
    public var topRight: Double
    public var bottomLeft: Double
    public var bottomRight: Double

    public init(topLeft: Double, topRight: Double, bottomLeft: Double, bottomRight: Double) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
    }

    public init(all: Double) {
        self.init(topLeft: all, topRight: all, bottomLeft: all, bottomRight: all)
    }
}