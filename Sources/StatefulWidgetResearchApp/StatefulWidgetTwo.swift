import WidgetGUI
import VisualAppBase
import CustomGraphicsMath

public class StatefulWidgetTwo: Widget, StatefulWidget {
    public struct State {
        var statePropertyOne: Double = 300
    }

    public var state: State = State()
    
    override open func layout() {
        bounds.size = DSize2(500, 500)
    }

    override open func renderContent() -> RenderObject? {
        RenderObject.RenderStyle(fillColor: FixedRenderValue(.Green)) {
            RenderObject.Rect(Rect(topLeft: globalPosition, size: DSize2(state.statePropertyOne, 300)))
        }
    }
}