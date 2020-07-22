import CustomGraphicsMath
import VisualAppBase

open class Background: SingleChildWidget {
    open var background: Color

    public init(background: Color, child: Widget) {
        self.background = background
        super.init(child: child)
    }

    public convenience init(background: Color, child: () -> Widget) {
        self.init(background: background, child: child())
    }

    override open func layout(fromChild: Bool = false) throws {
        child.constraints = constraints
        try child.layout()
        bounds.size = constraints!.constrain(child.bounds.size)
    }

    /*override open func render(renderer: R) throws {
        try renderer.rect(globalBounds, style: RenderStyle(fillColor: backgroundColor))
        try child.render(renderer: renderer)
    }*/
    override open func render(_ renderedChild: RenderObject?) -> RenderObject? {
        return .Container {
            RenderObject.RenderStyle(fillColor: FixedRenderValue(background)) {
                RenderObject.Rect(globalBounds)
            }
            renderedChild
        }
    }
}