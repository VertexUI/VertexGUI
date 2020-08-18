public protocol PlayerStateManager {
    var state: PlayerState { get }

    func retrieveUpdates()

    func perform(action: PlayerAction)
}