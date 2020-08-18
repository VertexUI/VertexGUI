public class Player {
    public var stateManager: PlayerStateManager

    public var state: PlayerState {
        stateManager.state
    }

    public init(stateManager: PlayerStateManager) {
        self.stateManager = stateManager
    }
}