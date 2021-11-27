
public protocol GUIKeyboardEvent {
    /// true if key is down, false if not
    var keyStates: KeyStatesContainer { get }
    var key: Key { get }
    var repetition: Bool { get }
}

extension GUIKeyboardEvent {
    // whether any of the ctrl keys was pressed when the event was fired
    var haveCtrl: Bool {
        keyStates[.leftCtrl] || keyStates[.rightCtrl]
    }

    // whether any of the gui keys is pressed (CMD on MacOS)
    var haveGui: Bool {
        keyStates[.leftGui] || keyStates[.rightGui]
    }
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