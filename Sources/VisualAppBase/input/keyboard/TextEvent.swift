public protocol TextEvent {
    var text: String { get }
}

public struct TextInputEvent: TextEvent {
    public var text: String

    public init(_ text: String) {
        self.text = text
    }
}