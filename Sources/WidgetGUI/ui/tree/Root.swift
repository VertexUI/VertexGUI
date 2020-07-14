import VisualAppBase
import CustomGraphicsMath

// TODO: maybe make this the root thing to render, and have a RenderStrategy
open class Root: Parent, MouseEventProvider {
    open var context: WidgetContext? {
        didSet {
            rootWidget.context = context
        }
    }
    
    open var bounds: DRect = DRect(topLeft: DPoint2(0,0), size: DSize2(0,0)) {
        didSet {
            try! layout()
        }
    }

    public var rootWidget: Widget
    public var mouseEventConsumers: [MouseEventConsumer] {
        get {
            return [rootWidget]
        }
        set {}
    }

    open var globalPosition: DPoint2 {
        get {
            return bounds.topLeft
        }
    }
    
    public init(rootWidget: Widget) {
        self.rootWidget = rootWidget
        //super.init()
        rootWidget.parent = self
    }

    open func layout(fromChild: Bool = false) throws {
        rootWidget.constraints = BoxConstraints(minSize: DSize2.zero, maxSize: bounds.size)
        try rootWidget.layout()
    }

    // TODO: is this needed here? or only for real widgets?
    open func relayout() throws {
        try layout(fromChild: true)
    }

    /*open func setup(with context: Context) throws {
        self.context = context
        _ = context.window.onMouse { event in
            // TODO: create mouse events specific for ui
            //try self.provideMouseEvent($0)
        }
    }*/

    open func render(renderer: Renderer) throws {
        //try renderer.clipArea(bounds: globalBounds)
        var renderObjectRenderer = RenderObjectRenderer(backendRenderer: renderer)
        var renderObject = try rootWidget.render()
        try renderObjectRenderer.render(renderObject!)
        //try renderer.releaseClipArea()
    }
}