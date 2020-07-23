import VisualAppBase
import CustomGraphicsMath

public class ScrollArea: SingleChildWidget {
    public static var defaultSpeed: Double = 40
    private var speed: Double
    private var currentY: Double = 0
    
    public init(speed: Double = ScrollArea.defaultSpeed, child: Widget) {
        self.speed = speed
        var mouseArea = MouseArea {
            child
        }
        super.init(child: mouseArea)
        _ = mouseArea.onMouseWheel(handleMouseWheel(_:))
    }

    public convenience init(speed: Double = ScrollArea.defaultSpeed, @WidgetBuilder child: () -> Widget) {
        self.init(speed: speed, child: child())
    }
    
    override open func layout(fromChild: Bool) throws {
        child.constraints = BoxConstraints(minSize: constraints!.minSize, maxSize: DSize2(constraints!.maxSize.width, Double.infinity))
        try child.layout()
        bounds.size = constraints!.constrain(child.bounds.size)
    }

    private func handleMouseWheel(_ event: GUIMouseWheelEvent) {
        currentY += event.scrollAmount.y * speed
        if currentY > 0 {
            currentY = 0
        } else if currentY < bounds.size.y - child.bounds.size.y {
            currentY = bounds.size.y - child.bounds.size.y
        }
        invalidateRenderState()
    }

    override public func render(_ renderedChild: RenderObject?) -> RenderObject? {
        return RenderObject.Translation(DVec2(0, currentY)) {
            renderedChild
        }
    }
}
