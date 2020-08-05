import Dispatch
import Foundation
import CustomGraphicsMath

public class GameManager {
    private var _nextBlobId: UInt = 0
    private var nextBlobId: UInt {
        get {
            defer { _nextBlobId += 1 }
            return _nextBlobId
        }
    }
    private var state: GameState
    private var foodTimebuffer: Double = 0
    private var ruleset: GameRuleset
    
    public init(state: GameState, ruleset: GameRuleset) {
        self.state = state
        self.ruleset = ruleset
    }

    private func getFrictionDeceleration(mass: Double) -> Double {
        return mass / 10
    }

    /// - Parameter deltaTime: Time since last call to update, in TimeUnits.
    public func update(deltaTime: Double) {
        for var (id, blob) in state.blobs {
            let previousPosition = blob.position

            if var blob = blob as? PlayerBlob {
                let previousAcceleration = blob.acceleration

                let maxAcceleration = ruleset.calcMaxAcceleration(blob.mass)
                blob.maxAcceleration = maxAcceleration

                blob.acceleration = blob.accelerationDirection * blob.accelerationFactor * blob.maxAcceleration

                if blob.acceleration != previousAcceleration {
                    state.eventQueue.append(GameEvent.Accelerate(id: blob.id, acceleration: blob.acceleration))
                }

                blob.speed += blob.acceleration * deltaTime

                let deceleration = getFrictionDeceleration(mass: blob.mass) * deltaTime
                let targetSpeedMagnitude = max(0, blob.speed.length - deceleration)

                blob.speed = blob.speed.normalized() * targetSpeedMagnitude

                blob.position += blob.speed * deltaTime

                if blob.position.x < state.areaBounds.min.x {
                    blob.position.x = state.areaBounds.min.x
                }
                if blob.position.y < state.areaBounds.min.y {
                    blob.position.y = state.areaBounds.min.y
                }
                if blob.position.x > state.areaBounds.max.x {
                    blob.position.x = state.areaBounds.max.x
                }
                if blob.position.y > state.areaBounds.max.y {
                    blob.position.y = state.areaBounds.max.y
                }

                for var (_, otherBlob) in state.blobs {
                    if otherBlob.id != blob.id {
                        checkConsume(&blob, &otherBlob)
                    }
                }
            }

            if previousPosition != blob.position {
                state.eventQueue.append(GameEvent.Move(id: blob.id, position: blob.position))
            }
        }
        balanceFood(deltaTime: deltaTime)
    }

    public func createPlayerBlob() -> PlayerBlob {
        let position = DVec2.random(in: state.areaBounds)
        let blob = PlayerBlob(
            id: nextBlobId,
            position: position,
            mass: ruleset.initialPlayerBlobMass,
            radius: ruleset.calcRadius(ruleset.initialPlayerBlobMass))
        state.blobs[blob.id] = blob
        state.eventQueue.append(GameEvent.Add(
            id: blob.id,
            type: blob.type,
            position: blob.position,
            radius: blob.radius))
        return blob
    }

    @discardableResult public func createFoodBlob(at position: DVec2) -> FoodBlob {
        let blob = FoodBlob(
            id: nextBlobId,
            position: position,
            mass: ruleset.foodBlobMass,
            radius: ruleset.calcRadius(ruleset.foodBlobMass))
        state.blobs[blob.id] = blob
        state.eventQueue.append(GameEvent.Add(
            id: blob.id,
            type: blob.type,
            position: blob.position,
            radius: blob.radius))
        return blob
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

        let targetFoodCount = Int(state.areaBounds.area * ruleset.minFoodDensity)

        let foodShortage = targetFoodCount - foodCount

        if foodShortage > 0 {
            foodTimebuffer += deltaTime

            let generationCount = Int(foodTimebuffer * ruleset.foodGenerationRate)
            
            foodTimebuffer -= Double(generationCount) / ruleset.foodGenerationRate

            for _ in 0..<generationCount {
                var foodPosition: DVec2
                var tries = 0
                repeat {
                    foodPosition = DVec2.random(in: state.areaBounds)
                    tries += 1
                } while tries < 20 && playerBlobs.contains { ($0.position - foodPosition).length < $0.radius }
                
                if tries < 20 {
                    createFoodBlob(at: foodPosition)
                }
            }
        }
    }

    /// Check whether the first passed blob consumes the second passed blob.
    private func checkConsume(_ blob1: inout PlayerBlob, _ blob2: inout Blob) {
        if blob1.consumed || blob2.consumed {
            return
        }
        if
            blob1.mass > blob2.mass,
            (blob2.position - blob1.position).length - blob1.radius < blob2.radius / 2 {
                blob2.consumed = true
         
                state.eventQueue.append(GameEvent.Remove(id: blob2.id))
                state.blobs.removeValue(forKey: blob2.id)
                
                blob1.mass += blob2.mass
                blob1.radius = ruleset.calcRadius(blob1.mass)
                
                state.eventQueue.append(GameEvent.Grow(id: blob1.id, radius: blob1.mass))
        }
    }
 
    public func popEventQueue() -> [GameEvent] {
        let queue = state.eventQueue 
        state.eventQueue = []
        return queue
    }
}