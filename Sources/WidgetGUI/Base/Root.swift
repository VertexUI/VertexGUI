import Foundation
import GfxMath
import Dispatch
import VisualAppBase
import Events

open class Root: Parent {
  open var bounds: DRect = DRect(min: DPoint2(0, 0), size: DSize2(0, 0)) {
    didSet {
      layout()
      rootWidget.invalidateRenderState()
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
      rootWidget.context = widgetContext!
    }
  }
  /* Widget lifecycle managment
  --------------------------------
  */
  // TODO: implement getTIck!
  lazy public private(set) var widgetLifecycleManager = Widget.LifecycleManager { Tick(deltaTime: 0, totalTime: 0) }
  public let widgetLifecycleBus = WidgetBus<WidgetLifecycleMessage>()
  private var widgetLifecycleMessages = WidgetBus<WidgetLifecycleMessage>.MessageBuffer()
  private var rebuildWidgets = WidgetBuffer()
  private var reboxConfigWidgets = WidgetBuffer()
  private var relayoutWidgets = WidgetBuffer()
  private var rerenderWidgets = WidgetBuffer()
  private var matchedStylesInvalidatedWidgets = WidgetBuffer()
  //private var focusContext = FocusContext()
  /* end Widget lifecycle management */

  private var mouseEventManager = WidgetTreeMouseEventManager()
  private var mouseMoveEventBurstLimiter = BurstLimiter(minDelay: 0.015)

  lazy private var styleManager = StyleManager(rootWidget: rootWidget)
  lazy private var experimentalStyleManager = Experimental.StyleManager()

  public var debugLayout = false {
    didSet {
      if let widgetContext = widgetContext {
        widgetContext.debugLayout = debugLayout
      }
    }
  }

  public private(set) var destroyed = false
  private var onDestroy = EventHandlerManager<Void>()

  public init(rootWidget contentRootWidget: Widget) {
    self.rootWidget = contentRootWidget
    _ = onDestroy(self.widgetLifecycleBus.pipe(into: widgetLifecycleMessages))
  }
  
  open func setup(
    window: Window,
    getTextBoundsSize: @escaping (_ text: String, _ fontConfig: FontConfig, _ maxWidth: Double?) -> DSize2,
    getApplicationTime: @escaping () -> Double,
    getRealFps: @escaping () -> Double,
    createWindow: @escaping (_ guiRootBuilder: @autoclosure () -> Root, _ options: Window.Options) -> Window,
    requestCursor: @escaping (_ cursor: Cursor) -> () -> Void
  ) {
    self.widgetContext = WidgetContext(
      window: window,
      getTextBoundsSize: getTextBoundsSize,
      getApplicationTime: getApplicationTime,
      getRealFps: getRealFps,
      createWindow: createWindow,
      requestCursor: requestCursor,
      queueLifecycleMethodInvocation: { [unowned self] in widgetLifecycleManager.queue($0, target: $1, sender: $2, reason: $3) },
      lifecycleMethodInvocationSignalBus: Bus<Widget.LifecycleMethodInvocationSignal>()
    )
    
    _ = rootWidget.onBoxConfigChanged { [unowned self] _ in
      layout()
    }

    rootWidget.mount(parent: self, context: widgetContext!, lifecycleBus: widgetLifecycleBus)
    //rootWidget.focusContext = focusContext

    styleManager.setup()
    experimentalStyleManager.processTree(rootWidget)
  }
  
  open func layout() {
    rootWidget.layout(constraints: BoxConstraints(minSize: bounds.size, maxSize: bounds.size))
  }

  @discardableResult
  open func consume(_ rawMouseEvent: RawMouseEvent) -> Bool {
    if let event = rawMouseEvent as? RawMouseMoveEvent {
      mouseMoveEventBurstLimiter.limit { [weak self] in
        self?.propagate(rawMouseEvent)
      }
    } else {
      propagate(rawMouseEvent)
    }

    return false
  }

  @discardableResult
  open func consume(_ rawKeyEvent: KeyEvent) -> Bool {
    propagate(rawKeyEvent)
    return false
  }

  @discardableResult
  open func consume(_ rawTextEvent: TextEvent) -> Bool {
    propagate(rawTextEvent)
    return false
  }

  open func tick(_ tick: Tick) {
    let startTime = Date.timeIntervalSinceReferenceDate

    widgetContext!.onTick.invokeHandlers(tick)

    for message in widgetLifecycleMessages {
      processLifecycleMessage(message)
    }
    widgetLifecycleMessages.clear()

    let removeOnAdd = widgetLifecycleMessages.onMessageAdded { [unowned self] in
      processLifecycleMessage($0)
    }

    for widget in rebuildWidgets {
      if !widget.destroyed {
        widget.build()
      }
    }
    styleManager.refresh(Array(rebuildWidgets))
    rebuildWidgets.clear()

    // TODO: check whether any parent of the widget was already processed (which automatically leads to a reprocessing of the styles)
    // TODO: or rather follow the pattern of invalidate...()? --> invalidateStyle()
    styleManager.refresh(Array(matchedStylesInvalidatedWidgets))
    for widget in matchedStylesInvalidatedWidgets {
      if !widget.destroyed && widget.mounted {
        experimentalStyleManager.processTree(widget)
      }
    }
    matchedStylesInvalidatedWidgets.clear()

    for widget in reboxConfigWidgets {
      if widget.mounted {
        widget.updateBoxConfig()
      }
    }
    reboxConfigWidgets.clear()
    
    //print("relayout widgets count", relayoutWidgets.count)
    for widget in relayoutWidgets {
      // the widget should only be relayouted if it hasn't been layouted before
      // if it hasn't been layouted before it will be layouted during
      // the first layout pass started by rootWidget.layout()
      if widget.layouted && !widget.destroyed {
        widget.layout(constraints: widget.previousConstraints!)
      }
    }
    relayoutWidgets.clear()

    // TODO: is it good to put this here or better in render()?
    //print("rerender widgets count", rerenderWidgets.count)
    for widget in rerenderWidgets {
      if !widget.destroyed {
        widget.updateRenderState()
      }
    }
    rerenderWidgets.clear()

    removeOnAdd()
    widgetLifecycleMessages.clear()
    //print("ONTICK TOOK", Date.timeIntervalSinceReferenceDate - startTime, "seconds")
  }

  @inline(__always)
  private func processLifecycleMessage(_ message: WidgetLifecycleMessage) {
    switch message.content {
    case .BuildInvalidated:
      rebuildWidgets.append(message.sender)
    case .MatchedStylesInvalidated:
      matchedStylesInvalidatedWidgets.append(message.sender)
    case .BoxConfigInvalidated:
      reboxConfigWidgets.append(message.sender)
    case .LayoutInvalidated:
      relayoutWidgets.append(message.sender)
    case .RenderStateInvalidated:
      rerenderWidgets.append(message.sender)
    }
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
    #if DEBUG
    let startTime = Date.timeIntervalSinceReferenceDate
    #endif

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

    #if DEBUG
    let deltaTime = Date.timeIntervalSinceReferenceDate - startTime
    Logger.log(
      "Took \(deltaTime) seconds for propagating a mouse event.",
      level: .Message, context: .Performance)
    #endif
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
    if destroyed {
      return
    }
    rootWidget.destroy()
    onDestroy.invokeHandlers(())
  }

  deinit {
    print("DEINITIALIZED ROOT")
    destroy()
  }
}

extension Root {
  class WidgetBuffer: Collection {
    typealias Index = Int
    typealias Element = Widget

    var widgets: [Widget] = []

    init() {}

    var count: Int {
      widgets.count
    }
 
    var startIndex: Int = 0

    var endIndex: Int {
      startIndex + count
    }

    subscript(position: Int) -> Widget {
      widgets[position]
    }

    func index(after i: Int) -> Int {
      i + 1
    }
    
    func makeIterator() -> WidgetBufferIterator {
      WidgetBufferIterator(self)
    }

    func append(_ widget: Widget) {
      widgets.append(widget)
    }

    func clear() {
      widgets = []
    }
  }

  struct WidgetBufferIterator: IteratorProtocol {
    var buffer: WidgetBuffer
    var nextIndex = 0

    init(_ buffer: WidgetBuffer) {
      self.buffer = buffer
    }
    
    mutating func next() -> Widget? {
      if buffer.widgets.count == nextIndex {
        return nil
      } else {
        defer { nextIndex += 1 }
        return buffer.widgets[nextIndex]
      }
    }
  }
}