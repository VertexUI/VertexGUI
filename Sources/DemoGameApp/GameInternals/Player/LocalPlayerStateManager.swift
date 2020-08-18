public class LocalPlayerStateManager: PlayerStateManager {
    private var gameProcessor: GameProcessor
    public private(set) var state: PlayerState
    
    public init(gameProcessor: GameProcessor) {
        self.gameProcessor = gameProcessor
        self.state = gameProcessor.newPlayer()
    }
}
