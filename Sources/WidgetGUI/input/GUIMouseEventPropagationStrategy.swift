import VisualAppBase

/// There might be different approaches.
public class GUIMouseEventPropagationStrategy {
    private var previousMouseEventTarget: GUIMouseEventConsumer?

    public init() {}
    
    /// - Returns true if the event was consumed.
    /// TODO: go by render objects (some render objects need an id or something like that to then find the widgets they belong to) --> advantage: only click where there is content --> need a "sorted" render object tree / composition?
    /// --> might use the already rendered stuff and actually check the pixels for Widgets which are able to consume mouse events --> for others only check layoutBounds or renderBounds
    public func propagate(event rawMouseEvent: RawMouseEvent, through rootWidget: Widget) -> Bool {
        print("PROPAGATE")

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

        if let mouseEventTarget = mouseEventTarget {
            do {
                switch rawMouseEvent {
                case let rawMouseEvent as RawMouseMoveEvent:
                    print("HAVE MOUSE MOVE")
                    try mouseEventTarget.consume(GUIMouseMoveEvent(position: rawMouseEvent.position, previousPosition: rawMouseEvent.previousPosition))
                default:
                    print("Unsupported event.")
                }
            } catch {
                print("Error while processing mouse event", error)
                return false
            }
        }

        previousMouseEventTarget = mouseEventTarget
        return false
    }
}