public protocol KeyEvent {
    /// true if key is down, false if not
    var keyStates: KeyStatesContainer { get }
    var key: Key { get }
}

public struct KeyDownEvent: KeyEvent {
    public var keyStates: KeyStatesContainer
    public var key: Key

    public init(key: Key, keyStates: KeyStatesContainer) {
        self.keyStates = keyStates
        self.key = key
    }
}

public struct KeyUpEvent: KeyEvent {
    public var keyStates: KeyStatesContainer
    public var key: Key

    public init(key: Key, keyStates: KeyStatesContainer) {
        self.keyStates = keyStates
        self.key = key
    }
}