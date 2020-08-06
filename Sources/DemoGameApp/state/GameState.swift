import CustomGraphicsMath

public class GameState {
    public var blobs = [UInt: Blob]()
    public var areaBounds = DRect(min: DPoint2(-1000, -1000), max: DPoint2(1000, 1000))
    private var eventBuffers = [UInt: GameEventBuffer]()
    private var nextEventBufferId: UInt = 0

    public func register(buffer: GameEventBuffer) -> UInt {
        eventBuffers[nextEventBufferId] = buffer
        defer { nextEventBufferId += 1 }
        return nextEventBufferId
    }

    public func unregister(bufferId: UInt) {
        eventBuffers[bufferId] = nil
    }

    public func add(event: GameEvent) {
        for buffer in eventBuffers.values {
            buffer.add(event: event)
        }
    }
}