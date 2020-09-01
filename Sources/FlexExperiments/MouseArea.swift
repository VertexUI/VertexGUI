import VisualAppBase
import WidgetGUI

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
    
    public var onMouseButtonUp = EventHandlerManager<GUIMouseButtonUpEvent>()
    
    public var onMouseMove = EventHandlerManager<GUIMouseMoveEvent>()

    public var onMouseEnter = EventHandlerManager<GUIMouseEnterEvent>()

    public var onMouseLeave = EventHandlerManager<GUIMouseLeaveEvent>()

    public var onMouseWheel = EventHandlerManager<GUIMouseWheelEvent>()

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

                _ = self.onClick(onClickHandler)
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

    public func consume(_ event: GUIMouseEvent) throws {

        switch event {

        case let mouseButtonDownEvent as GUIMouseButtonDownEvent:

            try onMouseButtonDown.invokeHandlers(mouseButtonDownEvent)

        case let mouseButtonUpEvent as GUIMouseButtonUpEvent:

            try onMouseButtonUp.invokeHandlers(mouseButtonUpEvent)

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
        
        onMouseButtonUp.removeAllHandlers()

        onMouseEnter.removeAllHandlers()

        onMouseMove.removeAllHandlers()

        onMouseLeave.removeAllHandlers()

        onMouseWheel.removeAllHandlers()
    }
}
