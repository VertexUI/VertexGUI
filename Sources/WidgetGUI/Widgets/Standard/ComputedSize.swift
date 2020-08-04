import VisualAppBase
import CustomGraphicsMath

public class ComputedSize: SingleChildWidget {
    public typealias CalculationFunction = (_ constraints: BoxConstraints) -> BoxConstraints

    public var calculate: CalculationFunction

    private var inputChild: Widget

    /*public init(calculate: @escaping CalculationFunction, child inputChild: Widget) {
        self.calculate = calculate
        self.inputChild = inputChild
        super.init()
    }*/

    public init(@WidgetBuilder child inputChild: () -> Widget, calculate: @escaping CalculationFunction) {
        //self.init(calculate: calculate, child: inputChild())
        self.calculate = calculate
        self.inputChild = inputChild()
        super.init()
    }

    override open func buildChild() -> Widget {
        inputChild
    }

    override open func performLayout() {
        child.constraints = calculate(constraints!)
        child.layout()
        bounds.size = child.bounds.size
    }
}
