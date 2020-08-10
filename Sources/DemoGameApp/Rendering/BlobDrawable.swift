import CustomGraphicsMath
import Foundation

public class BlobDrawable<BlobState: Blob>: Drawable {
    public var blobState: BlobState
    
    public init(blobState: BlobState) {
        self.blobState = blobState
        super.init()
        self.bounds = DRect(center: blobState.position, size: DSize2.zero)
        updateVertices()
    }

    public func update(deltaTime: Double) {
        lifetime += deltaTime
        updateVertices()
    }

    public func updateVertices() {
        fatalError("updateVertices() not implemented.")
    }
}