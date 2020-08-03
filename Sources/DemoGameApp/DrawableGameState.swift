public class DrawableGameState {
    public var blobs: [DrawableBlob] = [] {
        didSet {
            print("DRAWABLE GAME STATE DID SET")
        }
    }
}