// TODO: find a better name, maybe; sounds too similar to MouseArea / Why need both even?
public class MouseInteraction: SingleChildWidget, GUIMouseEventConsumer {
    public enum State {
        case Normal
        case Hover
        case Active
    }

    private var stateChildren = [State: Widget]()
    
    private var state: State = .Normal
    
    public init(@WidgetBuilder normal: () -> Widget, @WidgetBuilder hover: () -> Widget) {
        stateChildren[.Normal] = normal()
        stateChildren[.Hover] = hover()
    }

    public init(@WidgetBuilder normal: () -> Widget, @WidgetBuilder hover: () -> Widget, @WidgetBuilder active: () -> Widget) {
        stateChildren[.Normal] = normal()
        stateChildren[.Hover] = hover()
        stateChildren[.Active] = active()
    }

    override open func buildChild() -> Widget {
        return stateChildren[state] ?? stateChildren[.Normal]!
    }

    public func consume(_ event: GUIMouseEvent) {
        switch event {
        case let event as GUIMouseEnterEvent:
            self.state = .Hover
        case let event as GUIMouseLeaveEvent:
            self.state = .Normal
        case let event as GUIMouseButtonDownEvent:
            self.state = .Active
        case let event as GUIMouseButtonUpEvent:
            if globalBounds.contains(point: event.position) {
                self.state = .Hover
            } else {
                self.state = .Normal
            }
        default:
            return
        }
        invalidateChild()
    }
}