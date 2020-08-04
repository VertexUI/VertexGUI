import CustomGraphicsMath

public class GameState {
    public var blobs = [UInt: Blob]()
    public var areaBounds = DRect(min: DPoint2(-1000, -1000), max: DPoint2(1000, 1000))
    public var eventQueue = [GameEvent]()
}