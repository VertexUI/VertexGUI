public class LocalPlayerStateManager: PlayerStateManager {
    private let gameProcessor: GameProcessor

    private let synchronize: (_ block: () -> ()) -> ()

    public let state: PlayerState
    
    public init(gameProcessor: GameProcessor, synchronize: @escaping (_ block: () -> ()) -> ()) {
        self.gameProcessor = gameProcessor
        self.synchronize = synchronize
        self.state = gameProcessor.newPlayer()
    }

    /// Synchronous. Blocked by GameProcessor updates.
    public func retrieveUpdates() {
        synchronize { [unowned self] in
            gameProcessor.update(playerState: state)
        }
    }

    /// TODO: should be asynchronous
    public func perform(action: PlayerAction) {
        synchronize { [unowned self] in
            gameProcessor.process(playerAction: action, id: state.player.id)
        }
    }
}
