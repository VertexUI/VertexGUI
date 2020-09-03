import VisualAppBase
import CustomGraphicsMath

@available(*, deprecated, message: "Use ConstrainedSize instead.")
public class ComputedSize: SingleChildWidget {
    public enum DimensionUnitValue {
        case Pixels(_ value: Double)
        case Percent(_ value: Double)
    }

    public typealias CalculationFunction = (_ constraints: BoxConstraints) -> BoxConstraints

    public var calculate: CalculationFunction

    private var childBuilder: () -> Widget

    /*public init(calculate: @escaping CalculationFunction, child inputChild: Widget) {
        self.calculate = calculate
        self.inputChild = inputChild
        super.init()
    }*/

    public init(@WidgetBuilder child childBuilder: @escaping () -> Widget, calculate: @escaping CalculationFunction) {
        //self.init(calculate: calculate, child: inputChild())
        self.calculate = calculate
        self.childBuilder = childBuilder
        super.init()
    }

    public convenience init(width: DimensionUnitValue? = nil, height: DimensionUnitValue? = nil, @WidgetBuilder child childBuilder: @escaping () -> Widget) {
        self.init(child: childBuilder, calculate: {
            let resultWidth: Double?
            switch width {
            case let .Pixels(value):
                resultWidth = value
            case let .Percent(value):
                resultWidth = $0.maxSize.width * (value / 100)
            default:
                resultWidth = nil
            }

            let resultHeight: Double?
            switch height {
            case let .Pixels(value):
                resultHeight = value
            case let .Percent(value):
                resultHeight = $0.maxSize.height * (value / 100)
            default:
                resultHeight = nil
            }

            return BoxConstraints(
                minSize: DSize2(resultWidth ?? $0.minSize.width, resultHeight ?? $0.minSize.height),
                maxSize: DSize2(resultWidth ?? $0.maxSize.width, resultHeight ?? $0.maxSize.height))
        })
    }

    override open func buildChild() -> Widget {
        childBuilder()
    }

    override open func performLayout() {
        child.constraints = calculate(constraints!)
        child.layout()
        bounds.size = child.bounds.size
    }
}
