import CustomGraphicsMath
import VisualAppBase

open class Background: SingleChildWidget {
    public enum Shape {       
        case Rectangle
        case RoundedRectangle(_ cornerRadii: CornerRadii)
    }
    
    open var background: Color
    open var shape: Shape

    private var inputChild: Widget

    public init(
        _ background: Color,
        shape: Shape = .Rectangle,
        @WidgetBuilder child inputChildBuilder: () -> Widget) {
            self.background = background
            self.shape = shape
            self.inputChild = inputChildBuilder()
            super.init()
    }

    override open func buildChild() -> Widget {
        inputChild
    }

    override open func performLayout() {
        child.constraints = constraints
        try child.layout()
        bounds.size = constraints!.constrain(child.bounds.size)
    }

    /*override open func render(renderer: R) throws {
        try renderer.rectangle(globalBounds, style: RenderStyle(fillColor: backgroundColor))
        try child.render(renderer: renderer)
    }*/
    override open func renderContent() -> RenderObject? {
        return .Container { [unowned self] in
            RenderObject.RenderStyle(fillColor: FixedRenderValue(background)) {
                if case let .Rectangle = shape {
                    RenderObject.Rectangle(globalBounds)
                } else if case let .RoundedRectangle(cornerRadii) = shape {
                    RenderObject.Rectangle(globalBounds, cornerRadii: cornerRadii)
                }
            }
            child.render()
        }
    }
}
