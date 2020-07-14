/*
public struct VectorLayout1<Vector: Vector> {
    public var axisDirections: 
}*/

// TODO: is this needed? or can just go by convention?
public struct VectorLayout2<Vector: Vector2> {
    public let up: Vector
    public let right: Vector
    public let down: Vector
    public let left: Vector

    public init(up: Vector, right: Vector, down: Vector, left: Vector) {
        self.up = up
        self.right = right
        self.down = down
        self.left = left
    }

    public static var bottomLeftToTopRight: Self {
        VectorLayout2(up: Vector(0, 1), right: Vector(1, 0), down: Vector(0, -1), left: Vector(-1, 0))
    }
    public static var topLeftToBottomRight: Self {
        VectorLayout2(up: Vector(0, -1), right: Vector(1, 0), down: Vector(0, 1), left: Vector(-1, 0))
    }
    public static var defaultLayout: Self {
        bottomLeftToTopRight
    }
}