
public protocol GUIKeyboardEvent {
    /// true if key is down, false if not
    var keyStates: KeyStatesContainer { get }
    var key: Key { get }
    var repetition: Bool { get }
}

public struct GUIKeyDownEvent: GUIKeyboardEvent {
    public var keyStates: KeyStatesContainer
    public var key: Key
    public var repetition: Bool

    public init(key: Key, keyStates: KeyStatesContainer, repetition: Bool = false) {
        self.keyStates = keyStates
        self.key = key
        self.repetition = repetition
    }
}

public struct GUIKeyUpEvent: GUIKeyboardEvent {
    public var keyStates: KeyStatesContainer
    public var key: Key
    public var repetition: Bool

    public init(key: Key, keyStates: KeyStatesContainer, repetition: Bool = false) {
        self.keyStates = keyStates
        self.key = key
        self.repetition = repetition
    }
}