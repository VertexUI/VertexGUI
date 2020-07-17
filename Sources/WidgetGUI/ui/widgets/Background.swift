import CustomGraphicsMath
import VisualAppBase

open class Background: SingleChildWidget {
    open var backgroundColor: Color

    public init(child: Widget, backgroundColor: Color) {
        self.backgroundColor = backgroundColor
        super.init(child: child)
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
    override open func render() -> RenderObject? {
        return .Container([
            RenderObject.RenderStyle(RenderStyle(fillColor: backgroundColor), [.Rect(globalBounds)]),
            child.render()
        ].compactMap { $0 })
    }
}