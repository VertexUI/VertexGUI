import VisualAppBase
import Foundation

public class WidgetTreeMouseEventManager {
    private var rootWidget: Widget

    //private var previousMouseEventTarget: GUIMouseEventConsumer?
    //private var previousMouseButtonDownEventTarget: (Widget & GUIMouseEventConsumer)?

    private var previousMouseButtonDownEventButton: MouseButton?

    //private var previousMouseMoveEventTarget: (Widget & GUIMouseEventConsumer)?

    private var previousMouseEventTargets: [ObjectIdentifier: [Widget]] = [
        ObjectIdentifier(GUIMouseButtonDownEvent.self): [],
        ObjectIdentifier(GUIMouseMoveEvent.self): [],
    ]

    public init(rootWidget: Widget) {
        self.rootWidget = rootWidget
    }

    /// - Returns true if the event was consumed.
    /// TODO: go by render objects (some render objects need an id or something like that to then find the widgets they belong to) --> advantage: only click where there is content --> need a "sorted" render object tree / composition?
    /// --> might use the already rendered stuff and actually check the pixels for Widgets which are able to consume mouse events --> for others only check layoutBounds or renderBounds
    public func propagate(_ rawMouseEvent: RawMouseEvent) -> Bool {
        // TODO: optimize by storing the target of previous event and checking it first
        var currentTargets: [Widget] = []

        var testMouseEventTargets: [Widget] = [rootWidget]

        while testMouseEventTargets.count > 0 {
            let testTarget = testMouseEventTargets.removeFirst()

            // TODO: this might be a lot of calculation, can optimize by successively removing x, y while traversing the testTargets
            if testTarget.globalBounds.contains(point: rawMouseEvent.position) {
                currentTargets.append(testTarget)
                var iterator = testTarget.visitChildren()
                while let child = iterator.next() {
                    testMouseEventTargets.insert(child, at: 0)
                }
            }
        }

        // to let the event bubble up
        // TODO: maybe implement a bubble down first and then call on target + bubble up after that
        //mouseEventTargets.reverse()

  // now use the information about the current targets and the previous targets to forward the events
        switch rawMouseEvent {
        case let event as RawMouseButtonDownEvent:
        previousMouseEventTargets[ObjectIdentifier(GUIMouseButtonDownEvent.self)] = currentTargets
        for target in currentTargets {
            //let currentPosition = currentTargetPositions[ObjectIdentifier(target)]!
            target.processMouseEvent(GUIMouseButtonDownEvent(button: event.button, position: event.position))
        }

        case let event as RawMouseButtonUpEvent:
        for previousDownEventTarget in previousMouseEventTargets[
            ObjectIdentifier(GUIMouseButtonDownEvent.self)]!
        {
            // TODO: need to calculate point translation here as well for the previous targets
            // TODO: or if something was a previous down target but the up is occurring on the outside, maybe force the position into the bounds of the widget?
            previousDownEventTarget.processMouseEvent(
            GUIMouseButtonUpEvent(button: event.button, position: event.position))
        }

        for target in currentTargets {
            //let currentPosition = currentTargetPositions[ObjectIdentifier(target)]!
            var wasPreviousTarget = false
            for previousTarget in previousMouseEventTargets[
            ObjectIdentifier(GUIMouseButtonDownEvent.self)]!
            {
            if previousTarget.mounted && previousTarget === target {
                previousTarget.processMouseEvent(
                GUIMouseButtonClickEvent(button: event.button, position: event.position))
                wasPreviousTarget = true
            }
            }

            if !wasPreviousTarget {
            target.processMouseEvent(GUIMouseButtonUpEvent(button: event.button, position: event.position))
            }
        }

        case let event as RawMouseMoveEvent:
        var previousTargets = previousMouseEventTargets[ObjectIdentifier(GUIMouseMoveEvent.self)]!

        for target in currentTargets {
            //let currentPosition = currentTargetPositions[ObjectIdentifier(target)]!
            //let translation = event.position - event.previousPosition

            // TODO: maybe instead of contains by object identity, use contains by Widget identity
            // --> same type, same position, same id
            if previousTargets.contains(where: { ObjectIdentifier($0) == ObjectIdentifier(target) }) {
            previousTargets.removeAll { ObjectIdentifier($0) == ObjectIdentifier(target) }
            // TODO: save the previous translated position for this target!
            target.processMouseEvent(
                GUIMouseMoveEvent(
                position: event.position, previousPosition: event.previousPosition))
            } else {
            target.processMouseEvent(GUIMouseEnterEvent(position: event.position))
            }
        }

        // the targets left in previousTargets are only those which were not targets of the current event
        // which means the mouse has left them
        for target in previousTargets {
            // TODO: save the previous translated position for this specific target and pass it here instead!
            target.processMouseEvent(GUIMouseLeaveEvent(previousPosition: event.previousPosition))
        }

        previousMouseEventTargets[ObjectIdentifier(GUIMouseMoveEvent.self)] = currentTargets

        case let event as RawMouseWheelEvent:
        for target in currentTargets {
            //let currentPosition = currentTargetPositions[ObjectIdentifier(target)]!
            target.processMouseEvent(
            GUIMouseWheelEvent(scrollAmount: event.scrollAmount, position: event.position))
        }
        default:
        print("Could not forward MouseEvent \(rawMouseEvent), not supported.")
        }
/*
        switch rawMouseEvent {
            case _ as RawMouseButtonDownEvent:
                previousMouseEventTargets[ObjectIdentifier(GUIMouseButtonDownEvent.self)] = []
                previousMouseButtonDownEventButton = nil

            default:
                break
        }

        switch rawMouseEvent {
        case let rawMouseButtonDownEvent as RawMouseButtonDownEvent:
            for mouseEventTarget in mouseEventTargets {
                mouseEventTarget.consume(
                    GUIMouseButtonDownEvent(
                        button: rawMouseButtonDownEvent.button,
                        position: rawMouseButtonDownEvent.position))
            }
            //previousMouseButtonDownEventTarget = mouseEventTarget
            previousMouseEventTargets[ObjectIdentifier(GUIMouseButtonDownEvent.self)]! = mouseEventTargets
            previousMouseButtonDownEventButton = rawMouseButtonDownEvent.button

        case let rawMouseButtonUpEvent as RawMouseButtonUpEvent:
            for previousTarget in previousMouseEventTargets[ObjectIdentifier(GUIMouseButtonDownEvent.self)]! {
                previousTarget.consume(
                    GUIMouseButtonUpEvent(
                        button: rawMouseButtonUpEvent.button,
                        position: rawMouseButtonUpEvent.position
                    )
                )
            }

            for mouseEventTarget in mouseEventTargets {
                /*try mouseEventTarget.consume(
                    GUIMouseButtonUpEvent(
                        button: rawMouseButtonUpEvent.button,
                        position: rawMouseButtonUpEvent.position))*/
                
            
                // after same button down and up on same element, generate click event

                if let previousButton = previousMouseButtonDownEventButton,
                    rawMouseButtonUpEvent.button == previousButton {

                    for previousTarget in previousMouseEventTargets[ObjectIdentifier(GUIMouseButtonDownEvent.self)]! {
                        if !previousTarget.destroyed && previousTarget.id == mouseEventTarget.id {
                            mouseEventTarget.consume(
                                GUIMouseButtonClickEvent(
                                    button: rawMouseButtonUpEvent.button,
                                    position: rawMouseButtonUpEvent.position))
                        }
                    }
                }
            }

        case let rawMouseEvent as RawMouseMoveEvent:
            let previousTargets = previousMouseEventTargets[ObjectIdentifier(GUIMouseMoveEvent.self)]!
            var stillPresentPreviousTargetIds = [UInt]()

            for i in 0..<mouseEventTargets.count {
                let currentTarget = mouseEventTargets[i]
                currentTarget.consume(GUIMouseMoveEvent(position: rawMouseEvent.position, previousPosition: rawMouseEvent.previousPosition))

                // TODO: maybe this check can be optimized in speed
                if previousTargets.contains(where: { !$0.destroyed && $0.id == currentTarget.id }) {
                    stillPresentPreviousTargetIds.append(currentTarget.id)
                } else {
                    currentTarget.consume(GUIMouseEnterEvent(position: rawMouseEvent.position))
                }
            }

            for previousTarget in previousTargets {
                // TODO: maybe this check can be optimized in speed
                if !previousTarget.destroyed && !stillPresentPreviousTargetIds.contains(previousTarget.id) {
                    previousTarget.consume(GUIMouseLeaveEvent(previousPosition: rawMouseEvent.previousPosition))
                }
            }

            previousMouseEventTargets[ObjectIdentifier(GUIMouseMoveEvent.self)] = mouseEventTargets

        case let rawMouseEvent as RawMouseWheelEvent:
            for mouseEventTarget in mouseEventTargets {
                mouseEventTarget.consume(GUIMouseWheelEvent(scrollAmount: rawMouseEvent.scrollAmount, position: rawMouseEvent.position))
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
        }*/*/


        //previousMouseEventTarget = mouseEventTarget
        return false
    }
}