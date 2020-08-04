public class DrawableGameState {
    public var blobs: [UInt: DrawableBlob] = [:] {
        didSet {
            print("DRAWABLE GAME STATE DID SET")
        }
    }
}