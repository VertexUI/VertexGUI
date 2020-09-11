import CustomGraphicsMath

public struct Tile {
    public enum Edge: String, CaseIterable {
        case Top, Right, Bottom, Left
    }

    /*public var translation: VectorProtocol

    public init(_ translation: VectorProtocol) {
        self.translation = translation
    }*/

    public static func edgeVertices<VectorProtocol: Vector2Protocol>(topLeft: VectorProtocol, vectorLayout layout: VectorLayout2<VectorProtocol> = .defaultLayout) -> [Edge: (VectorProtocol, VectorProtocol)] {
        return [
            .Top: (topLeft, topLeft + layout.right),
            .Right: (topLeft + layout.right, topLeft + layout.right + layout.down),
            .Bottom: (topLeft + layout.down, topLeft + layout.down + layout.right),
            .Left: (topLeft, topLeft + layout.down)
        ]
    }
}