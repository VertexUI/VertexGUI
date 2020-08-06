public class GameEventBuffer: Sequence {
    public typealias Element = GameEvent

    public typealias Iterator = IndexingIterator<[GameEvent]>

    private var events: [GameEvent] = []

    public __consuming func makeIterator() -> IndexingIterator<[GameEvent]> {
        events.makeIterator()
    }

    public func add(event: GameEvent) {
        events.append(event)
    }

    public func clear() {
        events = []
    }
}