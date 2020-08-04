import Dispatch
import Foundation
import CustomGraphicsMath

public class GameManager {    
    private var state: GameState
    private var consumableTimebuffer: Double = 0
    
    public init(state: GameState) {
        self.state = state
    }

    private func balanceConsumables(deltaTime: Double) {
        if state.blobs.count < 10 {
            consumableTimebuffer += deltaTime
            let additionCount = Int(consumableTimebuffer * 10)
            
            if additionCount > 0 {
                consumableTimebuffer = 0
            }

            for _ in 0..<additionCount {
                add(blob: Blob(
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
        }/* else if
            blob2.mass > blob1.mass,
            (blob2.position - blob1.position).length - blob2.radius < blob1.radius / 2 {
                blob1.consumed = true
                blob2.mass += blob1.mass
                state.eventQueue.append(GameEvent.Grow(id: blob2.id, radius: blob2.mass))
                // TODO: implement other get consumed event
        }*/
    }

    /// - Parameter deltaTime: Time since last call to update, in seconds.
    public func update(deltaTime: Double) {
        for (id, blob) in state.blobs {
            let step = deltaTime * 200
            let previousPosition = blob.position

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
        balanceConsumables(deltaTime: deltaTime)
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