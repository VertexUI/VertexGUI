import Dispatch
import Foundation
import GfxMath

public class GameProcessor {
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

    public func updateRuleset(_ ruleset: GameRuleset) {
        self.ruleset = ruleset

        for chunk in state.chunks {
            for id in chunk.blobs.keys {
                chunk.blobs[id]!.mass = ruleset.foodBlobMass
                chunk.blobs[id]!.radius = ruleset.calcRadius(chunk.blobs[id]!.mass)
            }
        }
    }

    /// - Parameter deltaTime: Time since last call to update, in TimeUnits.
    public func update(deltaTime: Double) {
        for var (id, blob) in state.playerBlobs {
            let previousPosition = blob.position

            let previousAcceleration = blob.acceleration

            let maxAcceleration = ruleset.calcMaxAcceleration(blob.mass)
            blob.maxAcceleration = maxAcceleration

            blob.acceleration = blob.accelerationDirection * blob.maxAcceleration

            if blob.acceleration != previousAcceleration {
                state.record(event: GameEvent.Accelerate(id: blob.id, acceleration: blob.acceleration))
            }

            blob.speed += blob.acceleration * deltaTime

            let deceleration = ruleset.frictionDeceleration * deltaTime
            var targetSpeedMagnitude = min(
                ruleset.calcMaxSpeed(blob.mass) * blob.speedLimit,
                max(0, blob.speed.length - deceleration))
            // TODO: make slowing down also take time!

            blob.speed = blob.speed.normalized() * targetSpeedMagnitude

            blob.position += blob.speed * deltaTime

            if blob.position.x < state.areaBounds.min.x {
                blob.position.x = state.areaBounds.min.x
                blob.speed.x = 0
            }
            if blob.position.y < state.areaBounds.min.y {
                blob.position.y = state.areaBounds.min.y
                blob.speed.y = 0
            }
            if blob.position.x > state.areaBounds.max.x {
                blob.position.x = state.areaBounds.max.x
                blob.speed.x = 0
            }
            if blob.position.y > state.areaBounds.max.y {
                blob.position.y = state.areaBounds.max.y
                blob.speed.y = 0
            }

            for chunk in state.findChunks(intersecting: blob.bounds) {
                for var (_, otherBlob) in chunk.blobs {
                    if otherBlob.id != blob.id {
                        checkConsume(&blob, &otherBlob)
                    }
                }
            }

            if previousPosition != blob.position {
                state.record(event: GameEvent.Move(id: blob.id, position: blob.position))
            }
 
            state.playerBlobs[id] = blob
        }
        balanceFood(deltaTime: deltaTime)
    }

    public func newPlayer() -> PlayerState {
        let blob = state.playerBlobs[createPlayerBlob()]!
        return PlayerState(player: blob, foods: [], otherPlayers: [])
    }

    /// Updates the given PlayerState with current values of GameState.
    public func update(playerState: PlayerState) {
        playerState.player = state.playerBlobs[playerState.player.id]!
        let perspective = playerState.player.perspective

        playerState.foods = [:]

        for chunk in state.findChunks(intersecting: perspective.visibleArea) {
            for blob in chunk.blobs.values {
                playerState.foods[blob.id] = blob
            }
        }
    }

    public func process(playerAction: PlayerAction, id: UInt) {
        switch playerAction {
        case let .Motion(accelerationDirection, speedLimit):
            state.playerBlobs[id]!.accelerationDirection = accelerationDirection
            state.playerBlobs[id]!.speedLimit = speedLimit
        }
    }

    public func createPlayerBlob() -> UInt {
        let position = DVec2.random(in: state.areaBounds)
        let blob = PlayerBlob(
            id: nextBlobId,
            position: position,
            mass: ruleset.initialPlayerBlobMass,
            radius: ruleset.calcRadius(ruleset.initialPlayerBlobMass))
        state.add(blob: blob)
        state.record(event: GameEvent.Add(
            id: blob.id,
            type: blob.type,
            position: blob.position,
            radius: blob.radius))
        return blob.id
    }

    @discardableResult public func createFoodBlob(at position: DVec2) -> UInt {
        let blob = FoodBlob(
            id: nextBlobId,
            position: position,
            mass: ruleset.foodBlobMass,
            radius: ruleset.calcRadius(ruleset.foodBlobMass))
        state.add(blob: blob)
        state.record(event: GameEvent.Add(
            id: blob.id,
            type: blob.type,
            position: blob.position,
            radius: blob.radius))
        return blob.id
    }

    private func balanceFood(deltaTime: Double) {
        var foodCount = 0

        for chunk in state.chunks {
            foodCount += chunk.blobs.count
        }

        let targetFoodCount = Int(state.areaBounds.area * ruleset.targettedFoodDensity)

        let foodShortage = targetFoodCount - foodCount

        if foodShortage > 0, ruleset.foodGenerationRate > 0 {
            foodTimebuffer += deltaTime

            let generationCount = Int(foodTimebuffer * ruleset.foodGenerationRate)
            
            foodTimebuffer -= Double(generationCount) / ruleset.foodGenerationRate

            for _ in 0..<generationCount {
                var foodPosition: DVec2
                var tries = 0
                repeat {
                    foodPosition = DVec2.random(in: state.areaBounds)
                    tries += 1
                } while tries < 20 && state.playerBlobs.values.contains { ($0.position - foodPosition).length < $0.radius }
                
                if tries < 20 {
                    createFoodBlob(at: foodPosition)
                }
            }
        }
    }

    /// Check whether the first passed blob consumes the second passed blob.
    private func checkConsume(_ blob1: inout PlayerBlob, _ blob2: inout FoodBlob) {
        if blob1.consumed || blob2.consumed {
            return
        }
        if
            blob1.mass > blob2.mass,
            (blob2.position - blob1.position).length - blob1.radius < blob2.radius / 2 {
                blob2.consumed = true
         
                state.record(event: GameEvent.Remove(id: blob2.id))
                guard let chunk = state.chunkAt(blob2.position) else {
                    preconditionFailure("No chunk found for blob: \(blob2)")
                }
                chunk.blobs.removeValue(forKey: blob2.id)
                
                blob1.mass += blob2.mass
                blob1.radius = ruleset.calcRadius(blob1.mass)
                
                state.record(event: GameEvent.Grow(id: blob1.id, radius: blob1.mass))
        }
    }
}