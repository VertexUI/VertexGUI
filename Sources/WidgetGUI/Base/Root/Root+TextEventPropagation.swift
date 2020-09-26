import VisualAppBase

public extension Root {
    internal func propagate(_ event: TextEvent) {
        if let focused = context?.focus as? GUITextEventConsumer {
            if let event = event as? TextInputEvent {
                focused.consume(GUITextInputEvent(event.text))
            }
        }
    }
}