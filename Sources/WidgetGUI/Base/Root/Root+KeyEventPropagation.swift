import VisualAppBase

public extension Root {
    internal func propagate(_ rawKeyEvent: KeyEvent) {
        if let focus = context?.focus as? GUIKeyEventConsumer {
            if let keyDownEvent = rawKeyEvent as? KeyDownEvent {
                focus.consume(
                    GUIKeyDownEvent(
                        key: keyDownEvent.key,
                        keyStates: keyDownEvent.keyStates,
                        repetition: keyDownEvent.repetition))
            } else if let keyUpEvent = rawKeyEvent as? KeyUpEvent {
                focus.consume(
                    GUIKeyUpEvent(
                        key: keyUpEvent.key,
                        keyStates: keyUpEvent.keyStates,
                        repetition: keyUpEvent.repetition))
            } else {
                fatalError("Unsupported event type: \(rawKeyEvent)")
            }
        }
    }
}