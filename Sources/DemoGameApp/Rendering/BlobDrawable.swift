import GfxMath
import Foundation

public class BlobDrawable<BlobState: Blob>: Drawable {
    public var blobState: BlobState
    
    public init(blobState: BlobState) {
        self.blobState = blobState
        super.init()
        self.bounds = DRect(center: blobState.position, size: DSize2.zero)
        generateVertices()
    }

    public func generateVertices() {
        fatalError("generateVertices() not implemented.")
    }
}