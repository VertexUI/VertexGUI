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

    public init(
        on eventHandlers: GUIMouseEventHandlerTuple? = nil,
        child: Widget) {
            if let eventHandlers = eventHandlers {
                if let onMouseButtonDownHandler = eventHandlers.buttonDown {
                    _ = self.onMouseButtonDown(onMouseButtonDownHandler)
                }
                if let onMouseMoveHandler = eventHandlers.move {
                    _ = self.onMouseMove(onMouseMoveHandler)
                }
            }
        super.init(child: child)
    }

    public convenience init(
        on eventHandlers: GUIMouseEventHandlerTuple? = nil,
        @WidgetBuilder child: () -> Widget) {
            self.init(on: eventHandlers, child: child())
    }

    override open func layout(fromChild: Bool = false) throws {
        child.constraints = constraints
        try child.layout()
        bounds.size = child.bounds.size
    }

    public func consume(_ event: GUIMouseEvent) throws {
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