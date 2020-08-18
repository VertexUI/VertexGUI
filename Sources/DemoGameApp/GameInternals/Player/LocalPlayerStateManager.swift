public class LocalPlayerStateManager: PlayerStateManager {
    private let gameProcessor: GameProcessor

    private let synchronize: (_ block: () -> ()) -> ()

    public let state: PlayerState
    
    public init(gameProcessor: GameProcessor, synchronize: @escaping (_ block: () -> ()) -> ()) {
        self.gameProcessor = gameProcessor
        self.synchronize = synchronize
        self.state = gameProcessor.newPlayer()
    }

    public func retrieveUpdates() {
        synchronize { [unowned self] in
            gameProcessor.updatePlayer(state: state)
        }
    }
}
