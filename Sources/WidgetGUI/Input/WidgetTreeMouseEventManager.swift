import Foundation
import VisualAppBase
import GfxMath

public class WidgetTreeMouseEventManager {
  private var root: Root

  private var previousMouseButtonDownEventButton: MouseButton?

  private var previousMouseEventTargets: [ObjectIdentifier: [Widget]] = [
    ObjectIdentifier(GUIMouseButtonDownEvent.self): [],
    ObjectIdentifier(GUIMouseMoveEvent.self): [],
  ]

  public init(root: Root) {
    self.root = root
  }

  /// - Returns true if the event was consumed.
  /// TODO: go by render objects (some render objects need an id or something like that to then find the widgets they belong to) --> advantage: only click where there is content --> need a "sorted" render object tree / composition?
  /// --> might use the already rendered stuff and actually check the pixels for Widgets which are able to consume mouse events --> for others only check layoutBounds or renderBounds
  public func propagate(_ rawMouseEvent: RawMouseEvent) -> Bool {
    // to avoid having to apply the scale for every event type
    var processedRawMouseEvent = rawMouseEvent
    processedRawMouseEvent.position /= root.scale

    // TODO: optimize by storing the target of previous event and checking it first
    var currentTargets: [Widget] = []

    var testMouseEventTargets: [Widget] = [root.rootWidget]

    while testMouseEventTargets.count > 0 {
      let testTarget = testMouseEventTargets.removeFirst()

      if testTarget.globalBounds.contains(point: processedRawMouseEvent.position) {
        currentTargets.append(testTarget)
        var iterator = testTarget.children.makeIterator()
        while let child = iterator.next() {
          testMouseEventTargets.insert(child, at: 0)
        }
      }
    }

    // to let the event bubble up
    // TODO: maybe implement a bubble down first and then call on target + bubble up after that

    // now use the information about the current targets and the previous targets to forward the events
    switch processedRawMouseEvent {
    case let event as RawMouseButtonDownEvent:
      previousMouseEventTargets[ObjectIdentifier(GUIMouseButtonDownEvent.self)] = currentTargets
      for target in currentTargets {
        target.processMouseEvent(
          GUIMouseButtonDownEvent(
            button: event.button, position: event.position, globalPosition: event.position))
      }

    case let event as RawMouseButtonUpEvent:
      for previousDownEventTarget in previousMouseEventTargets[
        ObjectIdentifier(GUIMouseButtonDownEvent.self)]!
      {
        previousDownEventTarget.processMouseEvent(
          GUIMouseButtonUpEvent(
            button: event.button, position: event.position, globalPosition: event.position))
      }

      for target in currentTargets {
        var wasPreviousTarget = false
        for previousTarget in previousMouseEventTargets[
          ObjectIdentifier(GUIMouseButtonDownEvent.self)]!
        {
          if previousTarget.mounted && previousTarget === target {
            previousTarget.processMouseEvent(
              GUIMouseButtonClickEvent(
                button: event.button, position: event.position, globalPosition: event.position))
            wasPreviousTarget = true
          }
        }

        if !wasPreviousTarget {
          target.processMouseEvent(
            GUIMouseButtonUpEvent(
              button: event.button, position: event.position, globalPosition: event.position))
        }
      }

    case let event as RawMouseMoveEvent:
      var previousTargets = previousMouseEventTargets[ObjectIdentifier(GUIMouseMoveEvent.self)]!

      for target in currentTargets {
        // TODO: maybe instead of contains by object identity, use contains by Widget identity
        // --> same type, same position, same id
        if previousTargets.contains(where: { ObjectIdentifier($0) == ObjectIdentifier(target) }) {
          previousTargets.removeAll { ObjectIdentifier($0) == ObjectIdentifier(target) }
          // TODO: save the previous translated position for this target!
          target.processMouseEvent(
            GUIMouseMoveEvent(
              position: event.position, globalPosition: event.position,
              previousPosition: event.previousPosition / root.scale,
              previousGlobalPosition: event.previousPosition / root.scale))
        } else {
          target.processMouseEvent(
            GUIMouseEnterEvent(position: event.position, globalPosition: event.position))
        }
      }

      // the targets left in previousTargets are only those which were not targets of the current event
      // which means the mouse has left them
      for target in previousTargets {
        // TODO: save the previous translated position for this specific target and pass it here instead!
        target.processMouseEvent(
          GUIMouseLeaveEvent(position: event.position, globalPosition: event.position))
      }

      previousMouseEventTargets[ObjectIdentifier(GUIMouseMoveEvent.self)] = currentTargets

    case let event as RawMouseWheelEvent:
      for target in currentTargets {
        target.processMouseEvent(
          GUIMouseWheelEvent(
            scrollAmount: event.scrollAmount, position: event.position,
            globalPosition: event.position))
      }
    default:
      print("Could not forward MouseEvent \(rawMouseEvent), not supported.")
    }

    return false
  }
}
