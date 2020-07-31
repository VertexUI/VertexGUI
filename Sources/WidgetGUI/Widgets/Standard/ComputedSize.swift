import VisualAppBase
import CustomGraphicsMath

public class ComputedSize: SingleChildWidget {
    public typealias CalculationFunction = (_ constraints: BoxConstraints) -> DSize2

    public var calculate: CalculationFunction

    private var inputChild: Widget

    /*public init(calculate: @escaping CalculationFunction, child inputChild: Widget) {
        self.calculate = calculate
        self.inputChild = inputChild
        super.init()
    }*/

    public init(calculate: @escaping CalculationFunction, @WidgetBuilder child inputChild: () -> Widget) {
        //self.init(calculate: calculate, child: inputChild())
        self.calculate = calculate
        self.inputChild = inputChild()
        super.init()
    }

    override open func buildChild() -> Widget {
        inputChild
    }

    override open func performLayout() {
        bounds.size = calculate(constraints!)
        child.constraints = BoxConstraints(size: bounds.size)
        try child.layout()
    }
}
