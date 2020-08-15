import CustomGraphicsMath
import VisualAppBase

open class Background: SingleChildWidget {
    public struct Config {
        public var fill: Color
        public var shape: Shape

        public init(fill: Color, shape: Shape) {
            self.fill = fill
            self.shape = shape
        }
    }

    public enum Shape {       
        case Rectangle
        case RoundedRectangle(_ cornerRadii: CornerRadii)
    }
    
    private var config: Config

    private var inputChild: Widget

    public init(
        config: Config,
        @WidgetBuilder child inputChildBuilder: () -> Widget) {
            self.config = config
            self.inputChild = inputChildBuilder()
    }

    public convenience init(
        fill: Color,
        shape: Shape = Shape.Rectangle,
        @WidgetBuilder child inputChildBuilder: () -> Widget) {
            self.init(config: Config(fill: fill, shape: shape), child: inputChildBuilder)
    }

    override open func buildChild() -> Widget {
        inputChild
    }

    override open func performLayout() {
        child.constraints = constraints
        try child.layout()
        bounds.size = constraints!.constrain(child.bounds.size)
    }

    override open func renderContent() -> RenderObject? {
        return .Container { [unowned self] in
            RenderObject.RenderStyle(fillColor: FixedRenderValue(config.fill)) {
                if case .Rectangle = config.shape {
                    RenderObject.Rectangle(globalBounds)
                } else if case let .RoundedRectangle(cornerRadii) = config.shape {
                    RenderObject.Rectangle(globalBounds, cornerRadii: cornerRadii)
                }
            }
            child.render()
        }
    }
}
