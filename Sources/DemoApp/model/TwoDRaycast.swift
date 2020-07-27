import CustomGraphicsMath

public enum TwoDRaycastResult {
    case Hit(tileIndex: IVec2, edge: Tile.Edge)
    case Test(tileIndex: IVec2)
    case Intersection(position: DVec2)
}

public struct TwoDRaycast {
    public let start: DVec2
    public let end: DVec2
    public let results: [TwoDRaycastResult]

    public init(from start: DVec2, to end: DVec2, results: [TwoDRaycastResult]) {
        self.start = start
        self.end = end
        self.results = results
    }
}