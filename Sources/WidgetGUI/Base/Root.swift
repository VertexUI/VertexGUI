import CustomGraphicsMath
import Dispatch
import VisualAppBase

open class Root: Parent {
  open var bounds: DRect = DRect(min: DPoint2(0, 0), size: DSize2(0, 0)) {
    didSet {
      rootWidget.invalidateRenderState()
      layout()
    }
  }

  open var globalPosition: DPoint2 {
    return bounds.min
  }

  public var rootWidget: Widget
  open var widgetContext: WidgetContext? {
    didSet {
      if let widgetContext = widgetContext {
        widgetContext.debugLayout = debugLayout
      }
      rootWidget.context = widgetContext
    }
  }
  //private var focusContext = FocusContext()
  internal var layoutInvalidatedWidgets: [Widget] = []
  private var rerenderWidgets: [Widget] = []

  private var mouseEventManager = WidgetTreeMouseEventManager()
  private var mouseMoveEventBurstLimiter = BurstLimiter(minDelay: 0.015)

  public var debugLayout = false {
    didSet {
      if let widgetContext = widgetContext {
        widgetContext.debugLayout = debugLayout
      }
    }
  }

  public init(rootWidget contentRootWidget: Widget) {
    rootWidget = contentRootWidget
    rootWidget.mount(parent: self)
    //rootWidget.focusContext = focusContext

    _ = rootWidget.onBoxConfigChanged { [unowned self] _ in
      layout()
    }

    _ = rootWidget.onAnyLayoutInvalidated { [unowned self] in
      layoutInvalidatedWidgets.append($0)
    }

    _ = rootWidget.onAnyRenderStateInvalidated { [unowned self] in
      rerenderWidgets.append($0)
    }
  }

  open func layout() {
    rootWidget.layout(constraints: BoxConstraints(minSize: bounds.size, maxSize: bounds.size))
  }

  @discardableResult open func consume(_ rawMouseEvent: RawMouseEvent) -> Bool {
    if let event = rawMouseEvent as? RawMouseMoveEvent {
      mouseMoveEventBurstLimiter.limit { [weak self] in
        self?.propagate(rawMouseEvent)
      }
    } else {
      propagate(rawMouseEvent)
    }

    return false
  }

  @discardableResult open func consume(_ rawKeyEvent: KeyEvent) -> Bool {
    propagate(rawKeyEvent)
    return false
  }

  @discardableResult open func consume(_ rawTextEvent: TextEvent) -> Bool {
    propagate(rawTextEvent)
    return false
  }

  open func tick(_ tick: Tick) {
    // TODO: might do boxConfig recalculations here also
    for widget in layoutInvalidatedWidgets {
      widget.layout(constraints: widget.previousConstraints!)
    }

    // TODO: is it good to put this here or better in render()?
    for widget in rerenderWidgets {
      widget.updateRenderState()
    }

    rerenderWidgets = []
  }

  open func render() -> RenderObject? {
    return rootWidget.render()
  }

  /*
    Event Propagation
    --------------------
    */
  internal var previousMouseEventTargets: [ObjectIdentifier: [Widget & GUIMouseEventConsumer]] = [
    ObjectIdentifier(GUIMouseButtonDownEvent.self): [],
    ObjectIdentifier(GUIMouseMoveEvent.self): [],
  ]

  internal func propagate(_ event: RawMouseEvent) {
    // first get the current target widgets by performing a raycast over the render object tree
    var currentTargets = [Widget & GUIMouseEventConsumer]()
    var currentTargetPositions: [ObjectIdentifier: DPoint2] = [:]
    let renderObjectsAtPoint = self.rootWidget.render().objectsAt(point: event.position)
    for renderObjectAtPoint in renderObjectsAtPoint {
      if let object = renderObjectAtPoint.object as? IdentifiedSubTreeRenderObject {
        if let widget = rootWidget.getChild(where: { $0.id == object.id }) {
          if let widget = widget as? GUIMouseEventConsumer & Widget {
            currentTargets.append(widget)
            currentTargetPositions[ObjectIdentifier(widget)] = renderObjectAtPoint.transformedPoint
          }
        }
      }
    }

    // now use the information about the current targets and the previous targets to forward the events
    switch event {
    case let event as RawMouseButtonDownEvent:
      previousMouseEventTargets[ObjectIdentifier(GUIMouseButtonDownEvent.self)] = currentTargets
      for target in currentTargets {
        let currentPosition = currentTargetPositions[ObjectIdentifier(target)]!
        target.consume(GUIMouseButtonDownEvent(button: event.button, position: currentPosition))
      }

    case let event as RawMouseButtonUpEvent:
      for previousDownEventTarget in previousMouseEventTargets[
        ObjectIdentifier(GUIMouseButtonDownEvent.self)]!
      {
        // TODO: need to calculate point translation here as well for the previous targets
        // TODO: or if something was a previous down target but the up is occurring on the outside, maybe force the position into the bounds of the widget?
        previousDownEventTarget.consume(
          GUIMouseButtonUpEvent(button: event.button, position: event.position))
      }

      for target in currentTargets {
        let currentPosition = currentTargetPositions[ObjectIdentifier(target)]!
        var wasPreviousTarget = false
        for previousTarget in previousMouseEventTargets[
          ObjectIdentifier(GUIMouseButtonDownEvent.self)]!
        {
          if previousTarget.mounted && previousTarget === target {
            previousTarget.consume(
              GUIMouseButtonClickEvent(button: event.button, position: currentPosition))
            wasPreviousTarget = true
          }
        }

        if !wasPreviousTarget {
          target.consume(GUIMouseButtonUpEvent(button: event.button, position: currentPosition))
        }
      }

    case let event as RawMouseMoveEvent:
      var previousTargets = previousMouseEventTargets[ObjectIdentifier(GUIMouseMoveEvent.self)]!

      for target in currentTargets {
        let currentPosition = currentTargetPositions[ObjectIdentifier(target)]!
        let translation = currentPosition - event.position

        // TODO: maybe instead of contains by object identity, use contains by Widget identity
        // --> same type, same position, same id
        if previousTargets.contains(where: { ObjectIdentifier($0) == ObjectIdentifier(target) }) {
          previousTargets.removeAll { ObjectIdentifier($0) == ObjectIdentifier(target) }
          // TODO: save the previous translated position for this target!
          target.consume(
            GUIMouseMoveEvent(
              position: currentPosition, previousPosition: event.previousPosition + translation))
        } else {
          target.consume(GUIMouseEnterEvent(position: currentPosition))
        }
      }

      // the targets left in previousTargets are only those which were not targets of the current event
      // which means the mouse has left them
      for target in previousTargets {
        // TODO: save the previous translated position for this specific target and pass it here instead!
        target.consume(GUIMouseLeaveEvent(previousPosition: event.previousPosition))
      }

      previousMouseEventTargets[ObjectIdentifier(GUIMouseMoveEvent.self)] = currentTargets

    case let event as RawMouseWheelEvent:
      for target in currentTargets {
        let currentPosition = currentTargetPositions[ObjectIdentifier(target)]!
        target.consume(
          GUIMouseWheelEvent(scrollAmount: event.scrollAmount, position: currentPosition))
      }
    default:
      print("Could not forward MouseEvent \(event), not supported.")
    }
  }

  internal func propagate(_ rawKeyEvent: KeyEvent) {
    if let focus = widgetContext?.focusedWidget as? GUIKeyEventConsumer {
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

  internal func propagate(_ event: TextEvent) {
    if let focused = widgetContext?.focusedWidget as? GUITextEventConsumer {
      if let event = event as? TextInputEvent {
        focused.consume(GUITextInputEvent(event.text))
      }
    }
  }
  /*
    End Event Propagation
    ----------------------
    */

  open func destroy() {
    rootWidget.destroy()
  }
}
