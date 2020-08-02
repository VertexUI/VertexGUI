import WidgetGUI
import VisualAppBase
import CustomGraphicsMath

public class StatefulWidgetOne: SingleChildWidget, StatefulWidget {
    public struct State {
        var statePropertyOne: Color = .Blue
        var statePropertyTwo: String = "Default State String"
        var statePropertyThree: Int = 0
    }

    public var state: State = State()

    private var passedPropertyOne: String

    public init(passedPropertyOne: String) {
        self.passedPropertyOne = passedPropertyOne
    }

    override open func buildChild() -> Widget {
        Column { [unowned self] in
            Text(passedPropertyOne)

            Text("prop three is: \(state.statePropertyThree)")

            Button(onClick: { _ in
                state.statePropertyThree += 1
                invalidateChild()
            }) {
                Text("Click to invalidate Child one.")
            }
        }
    }
}
