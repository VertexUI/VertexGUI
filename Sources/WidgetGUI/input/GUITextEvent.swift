public protocol GUITextEvent {
    var text: String { get }
}

public struct GUITextInputEvent: GUITextEvent {
    public var text: String

    public init(_ text: String) {
        self.text = text
    }
}