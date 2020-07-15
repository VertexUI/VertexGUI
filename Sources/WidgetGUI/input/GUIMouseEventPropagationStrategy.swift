import VisualAppBase

/// There might be different approaches.
public class GUIMouseEventPropagationStrategy {
    private var previousMouseEventTarget: GUIMouseEventConsumer?
    private var previousMouseButtonDownEventTarget: (Widget & GUIMouseEventConsumer)?
    private var previousMouseButtonDownEventButton: MouseButton?
    private var previousMouseMoveEventTarget: (Widget & GUIMouseEventConsumer)?

    public init() {}
    
    /// - Returns true if the event was consumed.
    /// TODO: go by render objects (some render objects need an id or something like that to then find the widgets they belong to) --> advantage: only click where there is content --> need a "sorted" render object tree / composition?
    /// --> might use the already rendered stuff and actually check the pixels for Widgets which are able to consume mouse events --> for others only check layoutBounds or renderBounds
    public func propagate(event rawMouseEvent: RawMouseEvent, through rootWidget: Widget) -> Bool {
        // TODO: optimize by storing the target of previous event and checking it first

        var mouseEventTarget: (Widget & GUIMouseEventConsumer)?
        var testMouseEventTargets: [Widget] = [rootWidget]
        checkTargets: while testMouseEventTargets.count > 0 {
            for testTarget in testMouseEventTargets {
                // TODO: this might be a lot of calculation, can optimize by successively removing x, y while traversing the testTargets
                if testTarget.globalBounds.contains(point: rawMouseEvent.position) {
                    if let target = testTarget as? (Widget & GUIMouseEventConsumer) {
                        mouseEventTarget = target
                    }
                    switch testTarget {
                    case let testTarget as SingleChildWidget:
                        testMouseEventTargets = [testTarget.child]
                    case let testTarget as MultiChildWidget:
                        testMouseEventTargets = testTarget.children
                    default:
                        break checkTargets
                    }
                    continue checkTargets
                }
            }
            break
        }

        do {
            if let mouseEventTarget = mouseEventTarget {
                switch rawMouseEvent {
                case let rawMouseButtonDownEvent as RawMouseButtonDownEvent:
                    try mouseEventTarget.consume(
                        GUIMouseButtonDownEvent(
                            button: rawMouseButtonDownEvent.button,
                            position: rawMouseButtonDownEvent.position))
                    previousMouseButtonDownEventTarget = mouseEventTarget
                    previousMouseButtonDownEventButton = rawMouseButtonDownEvent.button

                case let rawMouseButtonUpEvent as RawMouseButtonUpEvent:
                    try mouseEventTarget.consume(
                        GUIMouseButtonUpEvent(
                            button: rawMouseButtonUpEvent.button,
                            position: rawMouseButtonUpEvent.position))
                    
                    // after same button down and up on same element, generate click event
                    if let previousTarget = previousMouseButtonDownEventTarget,
                        let previousButton = previousMouseButtonDownEventButton,
                        previousTarget === mouseEventTarget,
                        rawMouseButtonUpEvent.button == previousButton {
                            try mouseEventTarget.consume(
                                GUIMouseButtonClickEvent(
                                    button: rawMouseButtonUpEvent.button,
                                    position: rawMouseButtonUpEvent.position))
                    }
                    previousMouseButtonDownEventTarget = nil
                    previousMouseButtonDownEventButton = nil

                case let rawMouseEvent as RawMouseMoveEvent:
                    try mouseEventTarget.consume(GUIMouseMoveEvent(position: rawMouseEvent.position, previousPosition: rawMouseEvent.previousPosition))
                    // TODO: maybe check with internal ids
                    if let previousMoveTarget = previousMouseMoveEventTarget, previousMoveTarget !== mouseEventTarget {
                        try previousMoveTarget.consume(GUIMouseLeaveEvent(position: rawMouseEvent.position, previousPosition: rawMouseEvent.previousPosition))
                        try mouseEventTarget.consume(GUIMouseEnterEvent(position: rawMouseEvent.position, previousPosition: rawMouseEvent.previousPosition))
                        self.previousMouseMoveEventTarget = mouseEventTarget
                    } else if previousMouseMoveEventTarget == nil {
                        try mouseEventTarget.consume(GUIMouseEnterEvent(position: rawMouseEvent.position, previousPosition: rawMouseEvent.previousPosition))
                        self.previousMouseMoveEventTarget = mouseEventTarget
                    }
                default:
                    print("Unsupported event.")
                }
            } else {
                switch rawMouseEvent {
                case let rawMouseEvent as RawMouseMoveEvent:
                    if let previousMouseMoveEventTarget = previousMouseMoveEventTarget {
                        try previousMouseMoveEventTarget.consume(GUIMouseLeaveEvent(position: rawMouseEvent.position, previousPosition: rawMouseEvent.previousPosition))
                        self.previousMouseMoveEventTarget = nil
                    }
                default:
                    print("Unsupported event.")
                }
            }
        } catch {
            print("Error while processing mouse event", error)
            return false
        }

        previousMouseEventTarget = mouseEventTarget
        return false
    }
}