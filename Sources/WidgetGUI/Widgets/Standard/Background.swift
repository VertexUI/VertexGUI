import CustomGraphicsMath
import VisualAppBase

open class Background: SingleChildWidget {
    open var background: Color

    private var inputChild: Widget

    public init(_ background: Color, @WidgetBuilder child inputChildBuilder: () -> Widget) {
        self.background = background
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
        try renderer.rect(globalBounds, style: RenderStyle(fillColor: backgroundColor))
        try child.render(renderer: renderer)
    }*/
    override open func renderContent() -> RenderObject? {
        return .Container {
            RenderObject.RenderStyle(fillColor: FixedRenderValue(background)) {
                RenderObject.Rect(globalBounds)
            }
            child.render()
        }
    }
}
