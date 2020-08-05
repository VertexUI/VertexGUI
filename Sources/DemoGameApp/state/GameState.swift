import CustomGraphicsMath

public class GameState {
    public var rules = GameRules()
    public var blobs = [UInt: Blob]()
    public var areaBounds = DRect(min: DPoint2(-1000, -1000), max: DPoint2(1000, 1000))
    // TODO: rather have an OnGameEvent Event on the GameStateManager
    public var eventQueue = [GameEvent]()
}