import WidgetGUI
import VisualAppBase
import CustomGraphicsMath

public class StatefulView: SingleChildWidget, StatefulWidget, GUIMouseEventConsumer {
    public struct State {
        var viewStatePropertyOne: Color = .Red
        var viewStatePropertyTwo: String = "Default View State String"
    }

    public var state: State = State()

    private lazy var widgetTwo = childOfType(StatefulWidgetTwo.self)!

    override open func buildChild() -> Widget {
        Column {
            StatefulWidgetOne(passedPropertyOne: state.viewStatePropertyTwo)
            StatefulWidgetTwo()
        }
    }

    override open func performLayout() {
        child.constraints = constraints
        child.layout()
        bounds.size = child.bounds.size
    }

    public func consume(_ event: GUIMouseEvent) {
        if let event = event as? GUIMouseButtonClickEvent {
            if widgetTwo.globalBounds.contains(point: event.position) {
                state.viewStatePropertyTwo = "View State String After Click"
                invalidateChild()
            }
        }
    }
}
