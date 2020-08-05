public class DrawableGameStateManager {
  /*  private var state: GameState
    private var drawableState: DrawableGameState

    public init(state: GameState, drawableState: DrawableGameState) {
        self.state = state
        self.drawableState = drawableState
    }

    public func process(events: [GameEvent], deltaTime: Double) {
        for event in events {
            process(event: event, deltaTime: deltaTime)
        }
    }

    public func process(event: GameEvent, deltaTime: Double) {
        var updatedBlob: BlobDrawable?
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
            updatedBlob = blob
        case .Accelerate(let id, let acceleration):
            if let blob = drawableState.blobs[id] as? PlayerBlobDrawable {
                blob.acceleration = acceleration
                updatedBlob = blob
            }
        case .Move(let id, let position):
            if let blob = drawableState.blobs[id] {
                blob.position = position
                updatedBlob = blob
            }
        case .Grow(let id, let radius):
            if let blob = drawableState.blobs[id] {
                blob.radius = radius
                updatedBlob = blob
            }
        case .Remove(let id):
            drawableState.blobs.removeValue(forKey: id)
        }
        if let blob = updatedBlob {
            blob.update(deltaTime: deltaTime)
        }
    }*/
}