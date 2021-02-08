import VisualAppBase
import Events

public class MouseArea: SingleChildWidget, GUIMouseEventConsumer {
    public typealias GUIMouseEventHandlerTuple = (
        click: EventHandlerManager<GUIMouseButtonClickEvent>.Handler?,
        buttonDown: EventHandlerManager<GUIMouseButtonDownEvent>.Handler?,
        move: EventHandlerManager<GUIMouseMoveEvent>.Handler?
    )

    // TODO: maybe call it pointer event instead of mouse event / or provide both
    // TODO: maybe name Click MouseButtonClick?
    public var onMouseButtonDown = EventHandlerManager<GUIMouseButtonDownEvent>()
    public var onMouseButtonUp = EventHandlerManager<GUIMouseButtonUpEvent>()
    public var onMouseEnter = EventHandlerManager<GUIMouseEnterEvent>()
    public var onMouseLeave = EventHandlerManager<GUIMouseLeaveEvent>()
    private var inputChild: Widget

    public init(@WidgetBuilder child childBuilder: () -> Widget) {
        self.inputChild = childBuilder()
    }

    public convenience init(
        @WidgetBuilder child childBuilder: () -> Widget,
        onClick onClickHandler: EventHandlerManager<GUIMouseButtonClickEvent>.Handler? = nil,
        onMouseButtonDown onMouseButtonDownHandler: EventHandlerManager<GUIMouseButtonDownEvent>.Handler? = nil,
        onMouseButtonUp onMouseButtonUpHandler: EventHandlerManager<GUIMouseButtonUpEvent>.Handler? = nil,
        onMouseMove onMouseMoveHandler: EventHandlerManager<GUIMouseMoveEvent>.Handler? = nil,
        onMouseEnter onMouseEnterHandler: EventHandlerManager<GUIMouseEnterEvent>.Handler? = nil,
        onMouseLeave onMouseLeaveHandler: EventHandlerManager<GUIMouseLeaveEvent>.Handler? = nil,
        onMouseWheel onMouseWheelHandler: EventHandlerManager<GUIMouseWheelEvent>.Handler? = nil) {
            self.init(child: childBuilder)

            if let onClickHandler = onClickHandler {
                self.onClick(onClickHandler)
            }

            if let onMouseButtonDownHandler = onMouseButtonDownHandler {
                _ = self.onMouseButtonDown(onMouseButtonDownHandler)
            }

            if let onMouseButtonUpHandler = onMouseButtonUpHandler {
                _ = self.onMouseButtonUp(onMouseButtonUpHandler)
            }

            if let onMouseMoveHandler = onMouseMoveHandler {
                _ = self.onMouseMove(onMouseMoveHandler)
            }

            if let onMouseEnterHandler = onMouseEnterHandler {
                _ = self.onMouseEnter(onMouseEnterHandler)
            }

            if let onMouseLeaveHandler = onMouseLeaveHandler {
                _ = self.onMouseLeave(onMouseLeaveHandler)
            }

            if let onMouseWheelHandler = onMouseWheelHandler {
                _ = self.onMouseWheel(onMouseWheelHandler)
            }
    }

    override open func buildChild() -> Widget {
        return inputChild
    }

    public func consume(_ event: GUIMouseEvent) {
        switch event {
        case let mouseButtonDownEvent as GUIMouseButtonDownEvent:
            onMouseButtonDown.invokeHandlers(mouseButtonDownEvent)

        case let mouseButtonUpEvent as GUIMouseButtonUpEvent:
            onMouseButtonUp.invokeHandlers(mouseButtonUpEvent)

        case let mouseButtonClickEvent as GUIMouseButtonClickEvent:
            onClick.invokeHandlers(mouseButtonClickEvent)

        case let mouseMoveEvent as GUIMouseMoveEvent:
            onMouseMove.invokeHandlers(mouseMoveEvent)

        case let mouseEnterEvent as GUIMouseEnterEvent:
            onMouseEnter.invokeHandlers(mouseEnterEvent)

        case let mouseLeaveEvent as GUIMouseLeaveEvent:
            onMouseLeave.invokeHandlers(mouseLeaveEvent)

        case let mouseWheelEvent as GUIMouseWheelEvent:
            onMouseWheel.invokeHandlers(mouseWheelEvent)

        default:
            print("Unsupported event", event)
        }
    }

    override open func destroySelf() {
        onMouseButtonDown.removeAllHandlers()
        onMouseButtonUp.removeAllHandlers()
        onMouseEnter.removeAllHandlers()
        onMouseMove.removeAllHandlers()
        onMouseLeave.removeAllHandlers()
        onMouseWheel.removeAllHandlers()
    }
}
