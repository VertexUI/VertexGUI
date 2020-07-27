import CustomGraphicsMath

public struct Tile {
    public enum Edge: CaseIterable {
        case Top, Right, Bottom, Left
    }

    /*public var translation: Vector

    public init(_ translation: Vector) {
        self.translation = translation
    }*/

    public static func edgeVertices<Vector: Vector2>(topLeft: Vector, vectorLayout layout: VectorLayout2<Vector> = .defaultLayout) -> [Edge: (Vector, Vector)] {
        return [
            .Top: (topLeft, topLeft + layout.right),
            .Right: (topLeft + layout.right, topLeft + layout.right + layout.down),
            .Bottom: (topLeft + layout.down, topLeft + layout.down + layout.right),
            .Left: (topLeft, topLeft + layout.down)
        ]
    }
}