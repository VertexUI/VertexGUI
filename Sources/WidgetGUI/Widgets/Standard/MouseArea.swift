import VisualAppBase

public class MouseArea: SingleChildWidget, GUIMouseEventConsumer {
    public typealias GUIMouseEventHandlerTuple = (
        click: EventHandlerManager<GUIMouseButtonClickEvent>.Handler?,
        buttonDown: EventHandlerManager<GUIMouseButtonDownEvent>.Handler?,
        move: EventHandlerManager<GUIMouseMoveEvent>.Handler?
    )

    // TODO: maybe call it pointer event instead of mouse event / or provide both
    // TODO: maybe name Click MouseButtonClick?
    public var onClick = EventHandlerManager<GUIMouseButtonClickEvent>()
    public var onMouseButtonDown = EventHandlerManager<GUIMouseButtonDownEvent>()
    public var onMouseMove = EventHandlerManager<GUIMouseMoveEvent>()
    public var onMouseEnter = EventHandlerManager<GUIMouseEnterEvent>()
    public var onMouseLeave = EventHandlerManager<GUIMouseLeaveEvent>()
    public var onMouseWheel = EventHandlerManager<GUIMouseWheelEvent>()

    private var inputChild: Widget

    public init(
        onClick onClickHandler: EventHandlerManager<GUIMouseButtonClickEvent>.Handler? = nil,
        onMouseButtonDown onMouseButtonDownHandler: EventHandlerManager<GUIMouseButtonDownEvent>.Handler? = nil,
        onMouseMove onMouseMoveHandler: EventHandlerManager<GUIMouseMoveEvent>.Handler? = nil,
        onMouseWheel onMouseWheelHandler: EventHandlerManager<GUIMouseWheelEvent>.Handler? = nil,
        child inputChild: Widget) {
            if let onClickHandler = onClickHandler {
                _ = self.onClick(onClickHandler)
            }
            if let onMouseButtonDownHandler = onMouseButtonDownHandler {
                _ = self.onMouseButtonDown(onMouseButtonDownHandler)
            }
            if let onMouseMoveHandler = onMouseMoveHandler {
                _ = self.onMouseMove(onMouseMoveHandler)
            }
            if let onMouseWheelHandler = onMouseWheelHandler {
                _ = self.onMouseWheel(onMouseWheelHandler)
            }
            self.inputChild = inputChild
        super.init()
    }

    public convenience init(
        onClick onClickHandler: EventHandlerManager<GUIMouseButtonClickEvent>.Handler? = nil,
        onMouseButtonDown onMouseButtonDownHandler: EventHandlerManager<GUIMouseButtonDownEvent>.Handler? = nil,
        onMouseMove onMouseMoveHandler: EventHandlerManager<GUIMouseMoveEvent>.Handler? = nil,
        onMouseWheel onMouseWheelHandler: EventHandlerManager<GUIMouseWheelEvent>.Handler? = nil,
        @WidgetBuilder child: () -> Widget) {
            self.init(
                onClick: onClickHandler,
                onMouseButtonDown: onMouseButtonDownHandler,
                onMouseMove: onMouseMoveHandler,
                onMouseWheel: onMouseWheelHandler,
                child: child())
    }

    override open func buildChild() -> Widget {
        return inputChild
    }

    override open func layout(fromChild: Bool = false) throws {
        child.constraints = constraints
        try child.layout()
        bounds.size = child.bounds.size
    }

    public func consume(_ event: GUIMouseEvent) throws {
        print("MOUSE AREA CONSUME!")
        switch event {
        case let mouseButtonDownEvent as GUIMouseButtonDownEvent:
            try onMouseButtonDown.invokeHandlers(mouseButtonDownEvent)
        case let mouseButtonClickEvent as GUIMouseButtonClickEvent:
            try onClick.invokeHandlers(mouseButtonClickEvent)
        case let mouseMoveEvent as GUIMouseMoveEvent:
            try onMouseMove.invokeHandlers(mouseMoveEvent)
        case let mouseEnterEvent as GUIMouseEnterEvent:
            try onMouseEnter.invokeHandlers(mouseEnterEvent)
        case let mouseLeaveEvent as GUIMouseLeaveEvent:
            try onMouseLeave.invokeHandlers(mouseLeaveEvent)
        case let mouseWheelEvent as GUIMouseWheelEvent:
            try onMouseWheel.invokeHandlers(mouseWheelEvent)
        default:
            print("Unsupported event", event)
        }
        /*if let mouseButtonDownEvent = event as? GUIMouseButtonDownEvent {
            try onMouseButtonDown.invokeHandlers(mouseButtonDownEvent)
        } else if let mouseMoveEvent = event as? GUIMouseMoveEvent {
            try onMouseMove.invokeHandlers(mouseMoveEvent)
        } else if let */
    }
}