import Dispatch
import Foundation
import CustomGraphicsMath

public class GameManager {
    /// Food per LengthUnit².
    private var minFoodDensity: Double = 1 / 30

    /// Food per TimeUnit.
    private var foodGenerationRate: Double = 10 / 1

    /// Force that leads to acceleration of a blob. 
    private var accelerationForce: Double = 1000

    /// Force that reduces a blobs speed over time. In ForceUnit.
    private var frictionForce: Double = 2

    private var state: GameState
    private var foodTimebuffer: Double = 0
    
    public init(state: GameState) {
        self.state = state
    }

    private func balanceFood(deltaTime: Double) {
        var foodCount = 0
        var playerBlobs = [PlayerBlob]()

        for blob in state.blobs.values {
            if blob is FoodBlob {
                foodCount += 1
            } else if let blob = blob as? PlayerBlob {
                playerBlobs.append(blob)
            }
        }

        let targetFoodCount = Int(state.areaBounds.area * minFoodDensity)

        let foodShortage = targetFoodCount - foodCount

        if foodShortage > 0 {
            foodTimebuffer += deltaTime

            let generationCount = Int(foodTimebuffer * foodGenerationRate)
            
            foodTimebuffer -= Double(generationCount) / foodGenerationRate

            for _ in 0..<generationCount {
                var foodPosition: DVec2 
                repeat {
                    foodPosition = DVec2.random(in: state.areaBounds)
                } while playerBlobs.contains { ($0.position - foodPosition).length < $0.radius }

                add(blob: FoodBlob(
                    position: foodPosition,
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

    /// - Parameter deltaTime: Time since last call to update, in TimeUnits.
    public func update(deltaTime: Double) {
        for (id, blob) in state.blobs {
            let step = deltaTime * 200
            let previousPosition = blob.position

            if let blob = blob as? PlayerBlob {
                var newAcceleration = DVec2.zero
                var accelerationPotential = accelerationForce / blob.mass
                if blob.throttles[.Up]! {
                    newAcceleration.y += accelerationPotential
                }
                if blob.throttles[.Down]! {
                    newAcceleration.y -= accelerationPotential
                }
                if blob.throttles[.Right]! {
                    newAcceleration.x += accelerationPotential
                }
                if blob.throttles[.Left]! {
                    newAcceleration.x -= accelerationPotential
                }
                blob.acceleration = newAcceleration

                // TODO: add FRIcTION

                blob.speed += blob.acceleration * deltaTime

                blob.position += blob.speed * deltaTime
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
            type: blob.type,
            position: blob.position,
            radius: blob.radius))
    }

    public func popEventQueue() -> [GameEvent] {
        let queue = state.eventQueue 
        state.eventQueue = []
        return queue
    }
}