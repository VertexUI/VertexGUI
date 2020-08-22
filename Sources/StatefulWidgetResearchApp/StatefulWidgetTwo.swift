import WidgetGUI
import VisualAppBase
import CustomGraphicsMath

public class StatefulWidgetTwo: Widget, StatefulWidget {
    public struct State {
        var statePropertyOne: Double = 300
    }

    public var state: State = State()
    
    override open func performLayout() {
        bounds.size = DSize2(500, 500)
    }

    override open func renderContent() -> RenderObject? {
        RenderObject.RenderStyle(fillColor: .Green) {
            RenderObject.Rectangle(Rect(min: globalPosition, size: DSize2(state.statePropertyOne, 300)))
        }
    }
}
