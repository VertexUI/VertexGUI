import VisualAppBase
import WidgetGUI

public class MouseArea: SingleChildWidget, GUIMouseEventConsumer, BoxWidget {
    public typealias GUIMouseEventHandlerTuple = (
        click: ThrowingEventHandlerManager<GUIMouseButtonClickEvent>.Handler?,
        buttonDown: ThrowingEventHandlerManager<GUIMouseButtonDownEvent>.Handler?,
        move: ThrowingEventHandlerManager<GUIMouseMoveEvent>.Handler?
    )

    // TODO: maybe call it pointer event instead of mouse event / or provide both
    // TODO: maybe name Click MouseButtonClick?
    public var onClick = ThrowingEventHandlerManager<GUIMouseButtonClickEvent>()
    public var onMouseButtonDown = ThrowingEventHandlerManager<GUIMouseButtonDownEvent>()
    public var onMouseMove = ThrowingEventHandlerManager<GUIMouseMoveEvent>()
    public var onMouseEnter = ThrowingEventHandlerManager<GUIMouseEnterEvent>()
    public var onMouseLeave = ThrowingEventHandlerManager<GUIMouseLeaveEvent>()
    public var onMouseWheel = ThrowingEventHandlerManager<GUIMouseWheelEvent>()

    private var inputChild: Widget

    public init(@WidgetBuilder child childBuilder: () -> Widget) {
        self.inputChild = childBuilder()
    }

    public convenience init(
        @WidgetBuilder child childBuilder: () -> Widget,
        onClick onClickHandler: ThrowingEventHandlerManager<GUIMouseButtonClickEvent>.Handler? = nil,
        onMouseButtonDown onMouseButtonDownHandler: ThrowingEventHandlerManager<GUIMouseButtonDownEvent>.Handler? = nil,
        onMouseMove onMouseMoveHandler: ThrowingEventHandlerManager<GUIMouseMoveEvent>.Handler? = nil,
        onMouseEnter onMouseEnterHandler: ThrowingEventHandlerManager<GUIMouseEnterEvent>.Handler? = nil,
        onMouseLeave onMouseLeaveHandler: ThrowingEventHandlerManager<GUIMouseLeaveEvent>.Handler? = nil,
        onMouseWheel onMouseWheelHandler: ThrowingEventHandlerManager<GUIMouseWheelEvent>.Handler? = nil) {
            self.init(child: childBuilder)
            if let onClickHandler = onClickHandler {
                _ = self.onClick(onClickHandler)
            }
            if let onMouseButtonDownHandler = onMouseButtonDownHandler {
                _ = self.onMouseButtonDown(onMouseButtonDownHandler)
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

    public func getBoxConfig() -> BoxConfig {
        (child as! BoxWidget).getBoxConfig()
    }

    override open func performLayout() {
        child.constraints = constraints // legacy
        
        child.bounds.size = bounds.size

        child.layout()
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
        case let mouseWheelEvent as GUIMouseWheelEvent:
            try onMouseWheel.invokeHandlers(mouseWheelEvent)
        default:
            print("Unsupported event", event)
        }
    }

    override open func destroySelf() {
        onMouseButtonDown.removeAllHandlers()
        onMouseEnter.removeAllHandlers()
        onMouseMove.removeAllHandlers()
        onMouseLeave.removeAllHandlers()
        onMouseWheel.removeAllHandlers()
    }
}
