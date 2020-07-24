import VisualAppBase
import CustomGraphicsMath

public class ScrollArea: SingleChildWidget {
    public static var defaultSpeed: Double = 40
    private var speed: Double
    private var _currentX: Double = 0
    private var currentX: Double {
        get {
            return _currentX
        }
        set {
            _currentX = max(bounds.size.width - child.bounds.size.width, min(newValue, 0))
        }
    }
    private var _currentY: Double = 0
    private var currentY: Double {
        get {
            return _currentY
        }
        set {
            _currentY = max(bounds.size.height - child.bounds.size.height, min(newValue, 0))
        }
    }

    public init(speed: Double = ScrollArea.defaultSpeed, child: Widget) {
        self.speed = speed
        var mouseArea = MouseArea {
            child
        }
        super.init(child: mouseArea)
        _ = mouseArea.onMouseWheel(handleMouseWheel(_:))
        _ = mouseArea.onMouseMove(handleMouseMove(_:))
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
        currentX += event.scrollAmount.x * speed
        currentY += event.scrollAmount.y * speed
        invalidateRenderState()
    }

    private func handleMouseMove(_ event: GUIMouseMoveEvent) {
        currentX -= event.move.x
        currentY -= event.move.y
        invalidateRenderState()
    }

    override public func render(_ renderedChild: RenderObject?) -> RenderObject? {
        return RenderObject.Translation(DVec2(currentX, currentY)) {
            renderedChild
        }
    }
}
