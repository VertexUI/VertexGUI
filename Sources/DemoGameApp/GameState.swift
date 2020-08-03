import CustomGraphicsMath

public class GameState {
    public var blobs = [Blob]()
    public var areaBounds = DRect(min: DPoint2(0, 0), max: DPoint2(1000, 1000))
    public var eventQueue = [GameEvent]()
}