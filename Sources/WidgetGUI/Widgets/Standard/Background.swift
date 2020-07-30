import CustomGraphicsMath
import VisualAppBase

open class Background: SingleChildWidget {
    open var background: Color

    private var inputChildBuilder: () -> Widget

    public init(background: Color, @WidgetBuilder child inputChildBuilder: @escaping () -> Widget) {
        self.background = background
        self.inputChildBuilder = inputChildBuilder
        super.init()
    }

    override open func buildChild() -> Widget {
        inputChildBuilder()
    }

    override open func layout() {
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