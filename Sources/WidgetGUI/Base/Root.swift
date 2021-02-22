import Foundation
import GfxMath
import Dispatch
import VisualAppBase
import Events

open class Root: Parent {
  open var bounds: DRect = DRect(min: DPoint2(0, 0), size: DSize2(0, 0)) {
    didSet {
      layout()
    }
  }
  /** example: scale 2.0 -> the size of the root widget is halved
  and all coordinates and sizes are scaled by two (from the top left corner)
  -> content will be twice the size (e.g. text, images, fixed size widgets) */
  public var scale = 1.0 {
    didSet {
      layout()
    }
  }

  open var globalPosition: DPoint2 {
    return bounds.min
  }

  public var rootWidget: Widget

  var globalStylePropertySupportDefinitions = defaultStylePropertySupportDefinitions 
  var globalStyles = defaultGlobalStyles 
  var widgetContext: WidgetContext? {
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
  // TODO: implement getTick!
  lazy public private(set) var widgetLifecycleManager = Widget.LifecycleManager { Tick(deltaTime: 0, totalTime: 0) }
  public let widgetLifecycleBus = WidgetBus<WidgetLifecycleMessage>()
  private var widgetLifecycleMessages = WidgetBus<WidgetLifecycleMessage>.MessageBuffer()
  private var rebuildWidgets = WidgetBuffer()
  private var reboxConfigWidgets = WidgetBuffer()
  private var relayoutWidgets = WidgetBuffer()
  private var rerenderWidgets = WidgetBuffer()
  private var matchedStylesInvalidatedWidgets = WidgetBuffer()

  lazy var treeManager = WidgetTreeManager(widgetContext: widgetContext!, widgetLifecycleBus: widgetLifecycleBus)
  lazy var styleManager = StyleManager()
  lazy var cumulatedValuesProcessor = CumulatedValuesProcessor(self)
  /* end Widget lifecycle management */

  //private var focusContext = FocusContext()

  /* event propagation */
  lazy private var mouseEventManager = WidgetTreeMouseEventManager(root: self)
  private var mouseMoveEventBurstLimiter = BurstLimiter(minDelay: 0.015)
  /* end event propagation */

  /* debugging
  --------------------------
  */
  public let debugManager = DebugManager()

  public var debugLayout = false {
    didSet {
      if let widgetContext = widgetContext {
        widgetContext.debugLayout = debugLayout
      }
    }
  }

  /** this flag should be deleted once the direct draw call approach is fully implemented */
  public var renderObjectSystemEnabled = true
  /* end debugging */

  public private(set) var destroyed = false
  private var onDestroy = EventHandlerManager<Void>()

  public init(rootWidget contentRootWidget: Widget) {
    self.rootWidget = contentRootWidget
    _ = onDestroy(self.widgetLifecycleBus.pipe(into: widgetLifecycleMessages))
  }
  
  open func setup(
    window: Window,
    getTextBoundsSize: @escaping (_ text: String, _ fontConfig: FontConfig, _ maxWidth: Double?) -> DSize2,
    measureText: @escaping (_ text: String, _ paint: TextPaint) -> DSize2,
    getKeyStates: @escaping () -> KeyStatesContainer,
    getApplicationTime: @escaping () -> Double,
    getRealFps: @escaping () -> Double,
    createWindow: @escaping (_ guiRootBuilder: @autoclosure () -> Root, _ options: Window.Options) -> Window,
    requestCursor: @escaping (_ cursor: Cursor) -> () -> Void
  ) {
    self.widgetContext = WidgetContext(
      window: window,
      getTextBoundsSize: getTextBoundsSize,
      measureText: measureText,
      getKeyStates: getKeyStates,
      getApplicationTime: getApplicationTime,
      getRealFps: getRealFps,
      createWindow: createWindow,
      requestCursor: requestCursor,
      queueLifecycleMethodInvocation: { [unowned self] in widgetLifecycleManager.queue($0, target: $1, sender: $2, reason: $3) },
      lifecycleMethodInvocationSignalBus: Bus<Widget.LifecycleMethodInvocationSignal>(),
      globalStylePropertySupportDefinitions: globalStylePropertySupportDefinitions
    )

    //rootWidget.mount(parent: self, treePath: [], context: widgetContext!, lifecycleBus: widgetLifecycleBus)
    //rootWidget.focusContext = focusContext
    treeManager.mountAsRoot(widget: rootWidget, root: self)
    treeManager.buildSubTree(rootWidget: rootWidget)
    rootWidget.provideStyles(globalStyles)

    _ = rootWidget.onBoxConfigChanged { [unowned self] _ in
      layout()
    }

    styleManager.processTree(rootWidget)
  }
  
  open func layout() {
    rootWidget.layout(constraints: BoxConstraints(size: bounds.size / scale))
  }

  @discardableResult
  open func consume(_ rawMouseEvent: RawMouseEvent) -> Bool {
    if let event = rawMouseEvent as? RawMouseMoveEvent {
      mouseMoveEventBurstLimiter.limit { [weak self] in
        if let self = self {
          if !self.renderObjectSystemEnabled {
            self.mouseEventManager.propagate(rawMouseEvent)
          }
        }
      }
    } else {
      if !self.renderObjectSystemEnabled {
        mouseEventManager.propagate(rawMouseEvent)
      }
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
    debugManager.beginTick()

    let startTime = Date.timeIntervalSinceReferenceDate

    widgetContext!.onTick.invokeHandlers(tick)

    for message in widgetLifecycleMessages {
      processLifecycleMessage(message)
    }
    widgetLifecycleMessages.clear()

    let removeOnAdd = widgetLifecycleMessages.onMessageAdded { [unowned self] in
      processLifecycleMessage($0)
    }

    debugManager.beginLifecycleMethod(.build)
    for widget in rebuildWidgets {
      if !widget.destroyed {
        //widget.build()
        treeManager.buildChildren(of: widget)
      }
    }
    debugManager.endLifecycleMethod(.build)
    rebuildWidgets.clear()

    var iterator = widgetLifecycleManager.queues[.updateChildren]!.iterate()
    while let queueEntry = iterator.next() {
      treeManager.updateChildren(of: queueEntry.target)
    }
    widgetLifecycleManager.queues[.updateChildren]!.clear()

    // TODO: check whether any parent of the widget was already processed (which automatically leads to a reprocessing of the styles)
    // TODO: or rather follow the pattern of invalidate...()? --> invalidateStyle()
    var partialStartTime = Date.timeIntervalSinceReferenceDate
    for widget in matchedStylesInvalidatedWidgets {
      if !widget.destroyed && widget.mounted {
        styleManager.processTree(widget)
      }
    }
    //print("RESTYLE COUNT", matchedStylesInvalidatedWidgets.count)
    //print("RESTLYE TOOK", Date.timeIntervalSinceReferenceDate - partialStartTime)
    matchedStylesInvalidatedWidgets.clear()

    partialStartTime = Date.timeIntervalSinceReferenceDate
    let boxConfigQueue = widgetLifecycleManager.queues[.updateBoxConfig]!
    var boxConfigIterator = boxConfigQueue.iterate()
    while let entry = boxConfigIterator.next() {
      if entry.target.mounted {
        entry.target.updateBoxConfig()
      }
    }
    //print("REBOX COUNT", boxConfigQueue.entries.count)
    //print("REBOX TOOK", Date.timeIntervalSinceReferenceDate - partialStartTime)
    boxConfigQueue.clear()
    //reboxConfigWidgets.clear()
    
    //print("relayout widgets count", relayoutWidgets.count)
    let startTimeTwo = Date.timeIntervalSinceReferenceDate
    debugManager.beginLifecycleMethod(.layout)
    let layoutQueue = widgetLifecycleManager.queues[.layout]!
    var layoutIterator = layoutQueue.iterate()
    while let entry = layoutIterator.next() {
      // the widget should only be relayouted if it hasn't been layouted before
      // if it hasn't been layouted before it will be layouted during
      // the first layout pass started by rootWidget.layout()
      if entry.target.layouted && !entry.target.destroyed {
        entry.target.layout(constraints: entry.target.previousConstraints!)
      }
    }
    //print("LAYOUT COUNT", layoutQueue.entries.count)
    //print("LAYOUT TOOK", Date.timeIntervalSinceReferenceDate - startTimeTwo)
    layoutQueue.clear()
    debugManager.endLifecycleMethod(.layout)
    //relayoutWidgets.clear()

    partialStartTime = Date.timeIntervalSinceReferenceDate
    cumulatedValuesProcessor.processQueue()
    //print("CUMULATED VALUES TOOK", Date.timeIntervalSinceReferenceDate - partialStartTime)

    removeOnAdd()
    widgetLifecycleMessages.clear()
    //print("ONTICK TOOK", Date.timeIntervalSinceReferenceDate - startTime, "seconds")

    debugManager.endTick()
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

  open func draw(_ drawingContext: DrawingContext) {
    let rootDrawingContext = drawingContext.clone()
    rootDrawingContext.transform(.scale(DVec2(scale, scale)))
    rootDrawingContext.lock()

    var iterationStates = [(Parent, DrawingContext, Array<Widget>.Iterator)]()
    iterationStates.append((self, rootDrawingContext, [rootWidget].makeIterator()))

    outer: while var (parent, parentDrawingContext, iterator) = iterationStates.last {
      while let widget = iterator.next() {
        iterationStates[iterationStates.count - 1].2 = iterator

        if widget.visibility == .visible && widget.opacity > 0 {
          let childDrawingContext: DrawingContext = parentDrawingContext.clone()
          
          childDrawingContext.opacity = widget.opacity
          childDrawingContext.transform(.translate(widget.position))
          childDrawingContext.transform(widget.styleTransforms)
          // TODO: maybe the scrolling translation should be added to the parent widget context before adding the iterator to the list?
          if !widget.unaffectedByParentScroll, let parent = widget.parent as? Widget, parent.overflowX == .scroll || parent.overflowY == .scroll {
            childDrawingContext.transform(.translate(-parent.currentScrollOffset))
          }
          if widget.overflowX == .cut || widget.overflowX == .scroll || widget.overflowY == .cut || widget.overflowY == .scroll {
            let translationTestRect = drawingContext.preprocess(DRect(min: .zero, size: widget.size))
            var clipRect = translationTestRect

            if widget.overflowX == .cut || widget.overflowX == .scroll {
              clipRect.min.x = 0
              clipRect.size.x = widget.width
            }
            if widget.overflowY == .cut || widget.overflowY == .scroll {
              clipRect.min.y = 0
              clipRect.size.y = widget.height
            }

            childDrawingContext.clip(rect: clipRect)
          }
          childDrawingContext.lock()

          childDrawingContext.beginDrawing()

          if widget.background != .transparent {
            childDrawingContext.drawRect(rect: DRect(min: .zero, size: widget.size), paint: Paint(color: widget.background))
          }

          // TODO: probably the border should be drawn after all children have been drawn, to avoid the border being overlpassed
          if widget.borderColor != .transparent && widget.borderWidth != .zero {
            drawBorders(childDrawingContext, widget: widget)
          }

          if widget.padding.left != 0 || widget.padding.top != 0 {
            childDrawingContext.transform(.translate(DVec2(widget.padding.left, widget.padding.top)))
          }

          childDrawingContext.lock()

          if let leafWidget = widget as? LeafWidgetProtocol {
            leafWidget.draw(childDrawingContext)
          }

          childDrawingContext.endDrawing()

          if !(widget is LeafWidgetProtocol) {
            iterationStates.append((widget, childDrawingContext, widget.children.makeIterator()))
            continue outer
          }
        }
      }

      if let parent = parent as? Widget, parent.debugLayout {
        drawingContext.drawRect(rect: parent.globalBounds, paint: Paint(strokeWidth: 2.0, strokeColor: .red))
      }

      /*if let parent = parent as? Widget, parent.scrollingEnabled.x || parent.scrollingEnabled.y {
        parentDrawingContext.beginDrawing()
        parent.drawScrollbars(parentDrawingContext)
        parentDrawingContext.endDrawing()
      }*/

      iterationStates.removeLast()
    }
  }

  // TODO: maybe this function should be added to Widget
  private func drawBorders(_ drawingContext: DrawingContext, widget: Widget) {
    if widget.borderWidth.top > 0 {
      drawingContext.drawLine(
        from: DVec2(0, widget.borderWidth.top / 2),
        to: DVec2(widget.size.width, widget.borderWidth.top / 2),
        paint: Paint(strokeWidth: widget.borderWidth.top, strokeColor: widget.borderColor))
    }

    if widget.borderWidth.right > 0 {
      drawingContext.drawLine(
        from: DVec2(widget.bounds.width - widget.borderWidth.right / 2, 0),
        to: DVec2(widget.bounds.width - widget.borderWidth.right / 2, widget.bounds.height),
        paint: Paint(strokeWidth: widget.borderWidth.right, strokeColor: widget.borderColor))
    }

    if widget.borderWidth.bottom > 0 {
      drawingContext.drawLine(
        from: DVec2(0, widget.height - widget.borderWidth.bottom / 2),
        to: DVec2(widget.width, widget.height - widget.borderWidth.bottom / 2),
        paint: Paint(strokeWidth: widget.borderWidth.bottom, strokeColor: widget.borderColor))
    }

    if widget.borderWidth.left > 0 {
      drawingContext.drawLine(
        from: DVec2(widget.borderWidth.left / 2, 0), to: DVec2(widget.borderWidth.left / 2, widget.height),
        paint: Paint(strokeWidth: widget.borderWidth.left, strokeColor: widget.borderColor))
    }
  }

  /*
    Event Propagation
    --------------------
    */
  internal var previousMouseEventTargets: [ObjectIdentifier: [Widget & GUIMouseEventConsumer]] = [
    ObjectIdentifier(GUIMouseButtonDownEvent.self): [],
    ObjectIdentifier(GUIMouseMoveEvent.self): [],
  ]

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

  public class DebugManager {
    private var data = DebugData()
    private var currentTickData: DebugData.SingleTickData? = nil

    public init() {}

    public func beginTick() {
      currentTickData = DebugData.SingleTickData(startTimestamp: Date.timeIntervalSinceReferenceDate)
    }

    public func beginLifecycleMethod(_ method: Widget.LifecycleMethod) {
      if var currentTickData = currentTickData {
        currentTickData.lifecycleMethodInvocations[method] = DebugData.SingleTickData.LifecycleMethodInvocation(startTimestamp: Date.timeIntervalSinceReferenceDate)
        self.currentTickData = currentTickData
      }
    }

    public func endLifecycleMethod(_ method: Widget.LifecycleMethod) {
      if var currentTickData = currentTickData {
        if currentTickData.lifecycleMethodInvocations[method] != nil {
          currentTickData.lifecycleMethodInvocations[method]!.endTimestamp = Date.timeIntervalSinceReferenceDate
        }
        self.currentTickData = currentTickData
      }
    }

    @discardableResult
    public func endTick() -> DebugData.SingleTickData {
      guard var tick = currentTickData else {
        fatalError()
      }

      tick.endTimestamp = Date.timeIntervalSinceReferenceDate
      data.operations.append(.tick(tick))

      return tick
    }
  }

  public struct DebugData {
    public var operations: [Operation] = []

    public enum Operation {
      case tick(SingleTickData)
    }

    public struct SingleTickData: CustomDebugStringConvertible {
      public var startTimestamp: Double
      public var endTimestamp: Double = -1
      public var lifecycleMethodInvocations: [Widget.LifecycleMethod: LifecycleMethodInvocation] = [:]
      public var duration: Double {
        endTimestamp - startTimestamp
      }

      public struct LifecycleMethodInvocation: CustomDebugStringConvertible {
        public var startTimestamp: Double
        public var endTimestamp: Double = -1
        public var duration: Double {
          endTimestamp - startTimestamp
        }
        public var debugDescription: String {
          """
          Lifecycle Method Invocation { duration: \(duration)s }
          """
        }
      }

      public var debugDescription: String {
        """
        Tick Report {
          duration: \(duration)s
          invocations {
            \(lifecycleMethodInvocations.map { "\($0): \($1)" }.joined(separator: "\n\t"))
          }
        }
        """
      }
    }
  }
}