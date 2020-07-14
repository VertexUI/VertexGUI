public protocol KeyEvent {
    /// true if key is down, false if not
    var keyStates: [Key: Bool] { get }
    var key: Key { get }
}

public struct KeyDownEvent: KeyEvent {
    public var keyStates: [Key: Bool]
    public var key: Key

    public init(key: Key, keyStates: [Key: Bool]) {
        self.keyStates = keyStates
        self.key = key
    }
}

public struct KeyUpEvent: KeyEvent {
    public var keyStates: [Key: Bool]
    public var key: Key

    public init(key: Key, keyStates: [Key: Bool]) {
        self.keyStates = keyStates
        self.key = key
    }
}