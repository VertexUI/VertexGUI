import WidgetGUI
import VisualAppBase
import CustomGraphicsMath

public class StatefulView: SingleChildWidget, StatefulWidget {
    public struct State {
        var viewStatePropertyOne: String = "StatefulView prop one before click"
        var viewStatePropertyTwo: Bool = false
        var invalidationCount = 0
    }

    public var state: State = State()

    private lazy var widgetTwo = getChild(ofType: StatefulWidgetTwo.self)!

    override open func buildChild() -> Widget {
        Column(spacing: 32) {
            if state.viewStatePropertyTwo {
                Text("without additional wrapping")
                StatefulWidgetOne(passedPropertyOne: state.viewStatePropertyOne).keyed("test")
            } else {
                Row {
                    Text("with additional wrapping")
                    StatefulWidgetOne(passedPropertyOne: state.viewStatePropertyOne).keyed("test")
                }
            }

            Button {
                Text("Click to invalidate")
            } onClick: { [unowned self] _ in
                state.invalidationCount += 1
                state.viewStatePropertyOne = "View State String After invalidation \(state.invalidationCount)"
                state.viewStatePropertyTwo = !state.viewStatePropertyTwo 
                invalidateChild()
            } 
        }
    }

    override open func performLayout() {
        child.constraints = constraints
        child.layout()
        bounds.size = child.bounds.size
    }
}
