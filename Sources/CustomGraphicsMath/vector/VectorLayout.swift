/*
public struct VectorLayout1<VectorProtocol: VectorProtocol> {
    public var axisDirections: 
}*/

// TODO: is this needed? or can just go by convention?
public struct VectorLayout2<VectorProtocol: Vector2Protocol> {
    public let up: VectorProtocol
    public let right: VectorProtocol
    public let down: VectorProtocol
    public let left: VectorProtocol

    public init(up: VectorProtocol, right: VectorProtocol, down: VectorProtocol, left: VectorProtocol) {
        self.up = up
        self.right = right
        self.down = down
        self.left = left
    }

    public static var bottomLeftToTopRight: Self {
        VectorLayout2(up: VectorProtocol(0, 1), right: VectorProtocol(1, 0), down: VectorProtocol(0, -1), left: VectorProtocol(-1, 0))
    }
    public static var topLeftToBottomRight: Self {
        VectorLayout2(up: VectorProtocol(0, -1), right: VectorProtocol(1, 0), down: VectorProtocol(0, 1), left: VectorProtocol(-1, 0))
    }
    public static var defaultLayout: Self {
        bottomLeftToTopRight
    }
}