import CustomGraphicsMath
import VisualAppBase

public final class Background: SingleChildWidget, ConfigurableWidget {
    public struct Config: WidgetGUI.Config {
        public typealias PartialConfig = Background.PartialConfig

        public var fill: Color
        public var shape: Shape

        public init(fill: Color, shape: Shape) {
            self.fill = fill
            self.shape = shape
        }

        /*public init(partial partialConfig: PartialConfig?, default defaultConfig: Self) {
            self.fill = partialConfig?.fill ?? defaultConfig.fill
            self.shape = partialConfig?.shape ?? defaultConfig.shape
        }*/
    }

    public struct PartialConfig: WidgetGUI.PartialConfig {
        public var fill: Color?
        public var shape: Shape?

        public init() {}
    }

    public enum Shape {       
        case Rectangle
        case RoundedRectangle(_ cornerRadii: CornerRadii)
    } 

    public static let defaultConfig = Config(fill: .Transparent, shape: .Rectangle)    
    public var localConfig: Config?
    public var localPartialConfig: PartialConfig?
    lazy public var config: Config = combineConfigs()

    private var inputChild: Widget

    public init(
        @WidgetBuilder child inputChildBuilder: () -> Widget) {
            self.inputChild = inputChildBuilder()
    }

    public convenience init(
        fill: Color,
        shape: Shape = Shape.Rectangle,
        @WidgetBuilder child inputChildBuilder: () -> Widget) {
            self.init(child: inputChildBuilder)
            with(config: Config(fill: fill, shape: shape))
    }

    override public func buildChild() -> Widget {
        inputChild
    }

    override public func performLayout() {
        child.constraints = constraints
        try child.layout()
        bounds.size = constraints!.constrain(child.bounds.size)
    }

    override public func renderContent() -> RenderObject? {
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
