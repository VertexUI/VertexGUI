import Dispatch
import Foundation
import CustomGraphicsMath

public class GameManager {    
    private var state: GameState
    
    public init(state: GameState) {
        self.state = state
    }

    /// - Parameter deltaTime: Time since last call to update, in seconds.
    public func update(deltaTime: Double) {
        for i in 0..<state.blobs.count {
            let blob = state.blobs[i]

            let step = deltaTime * 200
            print("UPDATE BLOB", blob.throttles)
            if blob.throttles[.Up]! {
                print("UP ACTIVE")
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
            
            for otherBlob in state.blobs[i + 1..<state.blobs.count] {
                blob.interact(with: otherBlob)
            }
        }
    }
}