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
            drawableState.blobs.append(DrawableBlob(
                id: id, position: position, radius: radius, creationTimestamp: creationTimestamp))
        case .Move(let id, let position):
            for blob in drawableState.blobs {
                if blob.id == id {
                    blob.position = position
                    break
                }
            }
        case .Grow(let id, let radius):
            // TODO: implement id dictionary
            for blob in drawableState.blobs {
                if blob.id == id {
                    blob.radius = radius
                    break
                }
            }
        }
    }
}