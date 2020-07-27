import VisualAppBase
import Foundation

/// There might be different approaches.
// TODO: might merge this into Root
public class WidgetTreeMouseEventManager {
    //private var previousMouseEventTarget: GUIMouseEventConsumer?
    //private var previousMouseButtonDownEventTarget: (Widget & GUIMouseEventConsumer)?
    private var previousMouseButtonDownEventButton: MouseButton?
    //private var previousMouseMoveEventTarget: (Widget & GUIMouseEventConsumer)?
    private var previousMouseEventTargets: [ObjectIdentifier: [(Widget & GUIMouseEventConsumer)]] = [
        ObjectIdentifier(GUIMouseButtonDownEvent.self): [],
        ObjectIdentifier(GUIMouseMoveEvent.self): [],
    ]

    /// - Returns true if the event was consumed.
    /// TODO: go by render objects (some render objects need an id or something like that to then find the widgets they belong to) --> advantage: only click where there is content --> need a "sorted" render object tree / composition?
    /// --> might use the already rendered stuff and actually check the pixels for Widgets which are able to consume mouse events --> for others only check layoutBounds or renderBounds
    public func propagate(event rawMouseEvent: RawMouseEvent, through rootWidget: Widget) -> Bool {
        // TODO: optimize by storing the target of previous event and checking it first

        var mouseEventTargets: [(Widget & GUIMouseEventConsumer)] = []
        var testMouseEventTargets: [Widget] = [rootWidget]
        checkTargets: while testMouseEventTargets.count > 0 {
            for testTarget in testMouseEventTargets {
                // TODO: this might be a lot of calculation, can optimize by successively removing x, y while traversing the testTargets
                if testTarget.globalBounds.contains(point: rawMouseEvent.position) {
                    if let target = testTarget as? (Widget & GUIMouseEventConsumer) {
                        mouseEventTargets.append(target)
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

        print("MOUSE EVENT TARGETS COUNT", mouseEventTargets.count)

        // to let the event bubble up
        // TODO: maybe implement a bubble down first and then call on target + bubble up after that
        mouseEventTargets.reverse()

        do {
            switch rawMouseEvent {
                case let event as RawMouseButtonDownEvent:
                    previousMouseEventTargets[ObjectIdentifier(GUIMouseButtonDownEvent.self)] = []
                    previousMouseButtonDownEventButton = nil
                default:
                    break
            }

            switch rawMouseEvent {
            case let rawMouseButtonDownEvent as RawMouseButtonDownEvent:
                for mouseEventTarget in mouseEventTargets {
                    try mouseEventTarget.consume(
                        GUIMouseButtonDownEvent(
                            button: rawMouseButtonDownEvent.button,
                            position: rawMouseButtonDownEvent.position))
                }
                //previousMouseButtonDownEventTarget = mouseEventTarget
                previousMouseEventTargets[ObjectIdentifier(GUIMouseButtonDownEvent.self)]! = mouseEventTargets
                previousMouseButtonDownEventButton = rawMouseButtonDownEvent.button

            case let rawMouseButtonUpEvent as RawMouseButtonUpEvent:
                for mouseEventTarget in mouseEventTargets {
                    try mouseEventTarget.consume(
                        GUIMouseButtonUpEvent(
                            button: rawMouseButtonUpEvent.button,
                            position: rawMouseButtonUpEvent.position))
                
                    // after same button down and up on same element, generate click event
                    if let previousButton = previousMouseButtonDownEventButton,
                        rawMouseButtonUpEvent.button == previousButton {
                        for previousTarget in previousMouseEventTargets[ObjectIdentifier(GUIMouseButtonDownEvent.self)]! {
                            if previousTarget.id == mouseEventTarget.id {
                                try mouseEventTarget.consume(
                                    GUIMouseButtonClickEvent(
                                        button: rawMouseButtonUpEvent.button,
                                        position: rawMouseButtonUpEvent.position))
                            }
                        }
                    }
                }

            case let rawMouseEvent as RawMouseMoveEvent:
                let previousTargets = previousMouseEventTargets[ObjectIdentifier(GUIMouseMoveEvent.self)]!
                
                for i in 0..<mouseEventTargets.count {
                    let currentTarget = mouseEventTargets[i]
                    try currentTarget.consume(GUIMouseMoveEvent(position: rawMouseEvent.position, previousPosition: rawMouseEvent.previousPosition))
                    // TODO: maybe check with internal ids
                    /*if let previousMoveTarget = previousMouseMoveEventTarget, previousMoveTarget !== mouseEventTarget {
                        try previousMoveTarget.consume(GUIMouseLeaveEvent(position: rawMouseEvent.position, previousPosition: rawMouseEvent.previousPosition))
                        try mouseEventTarget.consume(GUIMouseEnterEvent(position: rawMouseEvent.position, previousPosition: rawMouseEvent.previousPosition))
                        self.previousMouseMoveEventTarget = mouseEventTarget
                    } else if previousMouseMoveEventTarget == nil {*/
                    if previousTargets.count > i {
                        let previousTarget = previousTargets[i]
                        if previousTarget.id != currentTarget.id {
                            try currentTarget.consume(GUIMouseEnterEvent(position: rawMouseEvent.position, previousPosition: rawMouseEvent.previousPosition))
                            try previousTarget.consume(GUIMouseLeaveEvent(position: rawMouseEvent.position, previousPosition: rawMouseEvent.previousPosition))
                        }
                    } else {
                        try currentTarget.consume(GUIMouseEnterEvent(position: rawMouseEvent.position, previousPosition: rawMouseEvent.previousPosition))
                    }
                }

                if mouseEventTargets.count < previousTargets.count {
                    for previousTarget in previousTargets[mouseEventTargets.count..<previousTargets.count] {
                        try previousTarget.consume(GUIMouseLeaveEvent(position: rawMouseEvent.position, previousPosition: rawMouseEvent.previousPosition))
                    }
                }

                previousMouseEventTargets[ObjectIdentifier(GUIMouseMoveEvent.self)] = mouseEventTargets

            case let rawMouseEvent as RawMouseWheelEvent:
                for mouseEventTarget in mouseEventTargets {
                    try mouseEventTarget.consume(GUIMouseWheelEvent(scrollAmount: rawMouseEvent.scrollAmount, position: rawMouseEvent.position))
                }
            default:
                print("Unsupported event.")
            }
            /* else {
                switch rawMouseEvent {
                case let rawMouseEvent as RawMouseMoveEvent:
                    if let previousMouseMoveEventTarget = previousMouseMoveEventTarget {
                        try previousMouseMoveEventTarget.consume(GUIMouseLeaveEvent(position: rawMouseEvent.position, previousPosition: rawMouseEvent.previousPosition))
                        self.previousMouseMoveEventTarget = nil
                    }
                default:
                    print("Unsupported event.")
                }
            }*/
        } catch {
            print("Error while processing mouse event", error)
            return false
        }

        //previousMouseEventTarget = mouseEventTarget
        return false
    }
}