import GfxMath

public class TwoDVoxelWorld {
    public var size: ISize2

    public init(size: ISize2) {
        self.size = size
    }

    public func raycast(from start: DVec2, to end: DVec2) -> TwoDRaycast {
        return TwoDRaycastStrategy().cast(in: self, from: start, to: end)
    }
}
