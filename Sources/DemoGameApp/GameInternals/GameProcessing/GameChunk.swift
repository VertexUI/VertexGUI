import CustomGraphicsMath

public class GameChunk {
    public static let size = DSize2(100, 100)
    
    public let index: IVec2

    public var blobs = [UInt: FoodBlob]()

    public init(index: IVec2) {
        self.index = index
    }
}

