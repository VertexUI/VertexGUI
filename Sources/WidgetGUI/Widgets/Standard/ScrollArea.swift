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
    private var scrollXEnabled = false
    private var scrollYEnabled = false
    private var scrollFactor = DVec2.zero
    private var scrollBarLength = DSize2.zero
    private var scrollBarWidth = DSize2(30, 30)
    private var visibleSize = DSize2.zero

    private var inputChild: Widget

    public init(speed: Double = ScrollArea.defaultSpeed, child inputChild: Widget) {
        self.speed = speed
        self.inputChild = inputChild
        super.init()
    }

    public convenience init(speed: Double = ScrollArea.defaultSpeed, @WidgetBuilder child: () -> Widget) {
        self.init(speed: speed, child: child())
    }

    override open func buildChild() -> Widget {
        let mouseArea = MouseArea({
            inputChild
        })
        // TODO: need to do like this to avoid strong reference? or is passing method reference enough
        _ = mouseArea.onMouseWheel({ [unowned self] in
            handleMouseWheel($0)
        })
        _ = mouseArea.onMouseMove({ [unowned self] in
            handleMouseMove($0)
        })
        return mouseArea
    }
    
    override open func performLayout() {
        child.constraints = BoxConstraints(minSize: constraints!.minSize, maxSize: DSize2(Double.infinity, Double.infinity))
        try child.layout()
        bounds.size = constraints!.constrain(child.bounds.size)
        
        if child.bounds.size.width > bounds.size.width {
            scrollXEnabled = true
        }
        if child.bounds.size.height > bounds.size.height {
            scrollYEnabled = true
        }
        if scrollXEnabled && !scrollYEnabled && bounds.size.height + scrollBarWidth.x > constraints!.maxHeight {
            scrollYEnabled = true
        }
        if scrollYEnabled && !scrollXEnabled && bounds.size.width + scrollBarWidth.y > constraints!.maxWidth {
            scrollXEnabled = true
        }

        if scrollXEnabled {
            bounds.size = constraints!.constrain(bounds.size + DSize2(0, scrollBarWidth.x))
        }
        if scrollYEnabled {
            bounds.size = constraints!.constrain(bounds.size + DSize2(scrollBarWidth.y, 0))
        }

        visibleSize.width = scrollYEnabled ? bounds.size.width - scrollBarWidth.y : bounds.size.width
        visibleSize.height = scrollXEnabled ? bounds.size.height - scrollBarWidth.x : bounds.size.height

        scrollFactor = DVec2(child.bounds.size / visibleSize)
        scrollBarLength = visibleSize * (DSize2(1, 1) / DSize2(scrollFactor))
    }

    private func handleMouseWheel(_ event: GUIMouseWheelEvent) {
        currentX += event.scrollAmount.x * speed
        currentY += event.scrollAmount.y * speed
        print("MOUSE WHEEL", event.scrollAmount)
        invalidateRenderState()
    }

    private func handleMouseMove(_ event: GUIMouseMoveEvent) {
        currentX -= event.move.x
        currentY -= event.move.y
        invalidateRenderState()
        print("MOUSE MOVE", event.move)
    }

    override public func renderContent() -> RenderObject? {
        var scrollBarX = RenderObject.Rect(DRect(
            min: DPoint2(globalPosition.x, globalPosition.y + globalBounds.size.height - scrollBarWidth.x),
            size: DSize2(scrollBarLength.x, scrollBarWidth.x)
        ))
        var scrollBarY = RenderObject.Rect(DRect(
            min: DPoint2(globalPosition.x + globalBounds.size.width - scrollBarWidth.x, globalPosition.y),
            size: DSize2(scrollBarWidth.x, scrollBarLength.y)
        ))
        return RenderObject.Container {
            RenderObject.Translation(DVec2(currentX, currentY)) {
                child.render()
            }
            RenderObject.RenderStyle(fillColor: FixedRenderValue(.Black)) {
                if scrollXEnabled {
                    scrollBarX
                }
                if scrollYEnabled {
                    scrollBarY
                }
            }
        }
    }
}
