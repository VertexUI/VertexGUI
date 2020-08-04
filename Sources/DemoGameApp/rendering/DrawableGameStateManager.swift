public class DrawableGameStateManager {
    private var drawableState: DrawableGameState

    public init(drawableState: DrawableGameState) {
        self.drawableState = drawableState
    }

    public func process(events: [GameEvent], deltaTime: Double) {
        for event in events {
            process(event: event, deltaTime: deltaTime)
        }
    }

    public func process(event: GameEvent, deltaTime: Double) {
        switch event {
        case .Add(let id, let type, let position, let radius):
            let blob: BlobDrawable
            switch type {
            case .Player:
                blob = PlayerBlobDrawable(
                    id: id, position: position, radius: radius)
            case .Food:
                blob = FoodBlobDrawable(
                    id: id, position: position, radius: radius)
            }
            drawableState.blobs[id] = blob
            blob.update(deltaTime: deltaTime)
        case .Move(let id, let position):
            if let blob = drawableState.blobs[id] {
                blob.position = position
                blob.update(deltaTime: deltaTime)
            }
        case .Grow(let id, let radius):
            if let blob = drawableState.blobs[id] {
                blob.radius = radius
                blob.update(deltaTime: deltaTime)
            }
        case .Remove(let id):
            drawableState.blobs.removeValue(forKey: id)
        }
    }
}