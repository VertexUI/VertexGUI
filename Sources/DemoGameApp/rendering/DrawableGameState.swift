import CustomGraphicsMath

public class DrawableGameState {
    //public var visibleAreaBounds = DRect()
    public var blobs: [UInt: BlobDrawable] = [:] {
        didSet {
            print("DRAWABLE GAME STATE DID SET")
        }
    }
    public var perspective = GamePerspective(visibleArea: DRect(min: .zero, max: .zero))
}