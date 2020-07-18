import VisualAppBase
import CustomGraphicsMath

// TODO: maybe make this the root thing to render, and have a RenderStrategy
open class Root: Parent {
    open var context: WidgetContext? {
        didSet {
            rootWidget.context = context
        }
    }
    
    open var bounds: DRect = DRect(topLeft: DPoint2(0,0), size: DSize2(0,0)) {
        didSet {
            try! layout()
            updateRenderTree()
        }
    }

    open var globalPosition: DPoint2 {
        get {
            return bounds.topLeft
        }
    }

    public var rootWidget: Widget

    private var widgetRenderTreeGenerator = WidgetRenderTreeGenerator()
    private var renderTreeRenderer = RenderTreeRenderer()
    private var renderTree: RenderTree?
    private var renderTreeInvalidated = false
    
    private var mouseEventPropagationStrategy = GUIMouseEventPropagationStrategy()

    public init(rootWidget: Widget) {
        self.rootWidget = rootWidget
        //super.init()
        rootWidget.parent = self
        // TODO: maybe dangling closure
        _ = rootWidget.onRenderStateInvalidated(updateRenderTree(_:))
    }

    open func layout(fromChild: Bool = false) throws {
        rootWidget.constraints = BoxConstraints(minSize: DSize2.zero, maxSize: bounds.size)
        try rootWidget.layout()
    }

    // TODO: is this needed here? or only for real widgets?
    open func relayout() throws {
        try layout(fromChild: true)
    }

    open func consumeMouseEvent(_ rawMouseEvent: RawMouseEvent) -> Bool {
        return mouseEventPropagationStrategy.propagate(event: rawMouseEvent, through: rootWidget)
    }

    /// - Parameter widget: If a specific widget is passed only the sub tree that was created by the widget will be updated.
    open func updateRenderTree(_ widget: Widget? = nil) {
        if let updatedWidget = widget, renderTree != nil {
            renderTreeRenderer.updateRenderTree(widgetRenderTreeGenerator.generate(updatedWidget))
        } else {
            renderTree = RenderTree([widgetRenderTreeGenerator.generate(rootWidget)])
            renderTreeRenderer.setRenderTree(renderTree!)
        }
    }

    // TODO: maybe this little piece of rendering logic belongs into the App as well? / Maybe return a render object as well???? 
    // TODO: --> A Game scene could also be a render object with custom logic which is redrawn on every frame by render strategy.
    open func render(renderer: Renderer) throws {
        //try renderer.clipArea(bounds: globalBounds)
        if renderTree == nil || renderTreeInvalidated {
            print("CALLING FROM HERE", renderTreeInvalidated)
            updateRenderTree()
            renderTreeInvalidated = false
        }
        try renderTreeRenderer.renderGroups(renderer, bounds: bounds)
    }
}