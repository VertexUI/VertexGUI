public class DrawableGameStateManager {
    private var drawableState: DrawableGameState

    public init(drawableState: DrawableGameState) {
        self.drawableState = drawableState
    }

    public func process(events: [GameEvent]) {
        for event in events {
            process(event: event)
        }
    }

    public func process(event: GameEvent) {
        switch event {
        case .Add(let id, let position, let radius, let creationTimestamp):
            let blob = DrawableBlob(
                id: id, position: position, radius: radius, creationTimestamp: creationTimestamp)
            drawableState.blobs[id] = blob
        case .Move(let id, let position):
            if let blob = drawableState.blobs[id] {
                blob.position = position
                break
            }
        case .Grow(let id, let radius):
            if let blob = drawableState.blobs[id] {
                blob.radius = radius
                break
            }
        case .Remove(let id):
            drawableState.blobs.removeValue(forKey: id)
        }
    }
}