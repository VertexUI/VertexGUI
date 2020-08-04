import Dispatch
import Foundation
import CustomGraphicsMath

public class GameManager {
    /// Food per square units.
    private var minFoodDensity: Double = 1 / 30
    /// Food per second.
    private var foodGenerationRate: Double = 10 / 1

    private var state: GameState
    private var foodTimebuffer: Double = 0
    
    public init(state: GameState) {
        self.state = state
    }

    private func balanceFood(deltaTime: Double) {
        var foodCount = 0

        for blob in state.blobs.values {
            if blob is FoodBlob {
                foodCount += 1
            }
        }

        let targetFoodCount = Int(state.areaBounds.area * minFoodDensity)

        let foodShortage = targetFoodCount - foodCount

        if foodShortage > 0 {
            foodTimebuffer += deltaTime

            let generationCount = Int(foodTimebuffer * foodGenerationRate)
            
            foodTimebuffer -= Double(generationCount) / foodGenerationRate

            for _ in 0..<generationCount {
                add(blob: FoodBlob(
                    position: DVec2.random(in: state.areaBounds),
                    mass: 10,
                    timestamp: Date.timeIntervalSinceReferenceDate))
            }
        }
    }

    private func removeConsumedBlobs() {
        for (id, blob) in state.blobs {
            if blob.consumed {
                state.eventQueue.append(GameEvent.Remove(id: id))
                state.blobs.removeValue(forKey: id)
            }
        }
    }

    /// Check whether the first passed blob consumes the second passed blob.
    public func checkCanConsume(_ blob1: Blob, _ blob2: Blob) {
        if blob1.consumed || blob2.consumed {
            return
        }
        if
            blob1.mass > blob2.mass,
            (blob2.position - blob1.position).length - blob1.radius < blob2.radius / 2 {
                blob2.consumed = true
                blob1.mass += blob2.mass
                state.eventQueue.append(GameEvent.Grow(id: blob1.id, radius: blob1.mass))
                // TODO: implement other get consumed event
        }
    }

    /// - Parameter deltaTime: Time since last call to update, in seconds.
    public func update(deltaTime: Double) {
        for (id, blob) in state.blobs {
            let step = deltaTime * 200
            let previousPosition = blob.position

            if let blob = blob as? PlayerBlob {
                if blob.throttles[.Up]! {
                    blob.position += DVec2(0, step)
                }
                if blob.throttles[.Down]! {
                    blob.position -= DVec2(0, step)
                }
                if blob.throttles[.Right]! {
                    blob.position += DVec2(step, 0)
                }
                if blob.throttles[.Left]! {
                    blob.position -= DVec2(step, 0)
                }
            }

            if previousPosition != blob.position {
                state.eventQueue.append(GameEvent.Move(id: blob.id, position: blob.position))
            }
            
            for (_, otherBlob) in state.blobs {
                if otherBlob !== blob {
                    checkCanConsume(blob, otherBlob)
                }
            }
        }
        removeConsumedBlobs()
        balanceFood(deltaTime: deltaTime)
    }

    public func add(blob: Blob) {
        state.blobs[blob.id] = blob
        state.eventQueue.append(GameEvent.Add(
            id: blob.id,
            position: blob.position,
            radius: blob.radius,
            creationTimestamp: blob.creationTimestamp))
    }

    public func popEventQueue() -> [GameEvent] {
        let queue = state.eventQueue 
        state.eventQueue = []
        return queue
    }
}