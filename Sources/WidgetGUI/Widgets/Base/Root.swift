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
            updateRenderObjectTree()
        }
    }

    open var globalPosition: DPoint2 {
        get {
            return bounds.topLeft
        }
    }

    public var rootWidget: Widget

    // TODO: might include this into this Root class, why need another small object for that...?
    private var widgetRenderObjectTreeGenerator = WidgetRenderObjectTreeGenerator()
    private var renderObjectTreeRenderer: RenderObjectTreeRenderer
    private var renderObjectTree: RenderObjectTree
    private var renderTreeInvalidated = false
    private var invalidatedWidgets = [UInt: Widget]()
    
    private var mouseEventPropagationStrategy = GUIMouseEventPropagationStrategy()

    public var onDebuggingDataAvailable = EventHandlerManager<RenderObjectTreeRenderer.DebuggingData>()

    public init(rootWidget contentRootWidget: Widget) {
        self.rootWidget = Column(children: [
            /*Background(
                background: Color(255, 255, 255, 255),
                child: Text("TEST")
            ),*/
            contentRootWidget
        ])
        //super.init()
        self.renderObjectTree = RenderObjectTree()
        self.renderObjectTreeRenderer = RenderObjectTreeRenderer(renderObjectTree)
        self.rootWidget.parent = self
        // TODO: maybe dangling closure
        _ = self.rootWidget.onRenderStateInvalidated {
            self.renderTreeInvalidated = true
            self.invalidatedWidgets[$0.id] = $0
        }
    }

    open func layout(fromChild: Bool = false) throws {
        rootWidget.constraints = BoxConstraints(minSize: DSize2.zero, maxSize: bounds.size)
        print("SET ROOT WIDGET CONSTRAINTS", bounds.size)
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
    open func updateRenderObjectTree(_ widget: Widget? = nil) {
        if renderObjectTree.children.count == 0 {
            // TODO: provide an insert action
            renderObjectTree.children.append(widgetRenderObjectTreeGenerator.generate(rootWidget))
            renderObjectTreeRenderer.refresh()
        } else {
            var updateWidget = widget ?? rootWidget
            let update = renderObjectTree.replace(widgetRenderObjectTreeGenerator.generate(updateWidget))
            renderObjectTreeRenderer.processUpdate(update)
            print("UPDATE RENDER TREE CALLED", widget)
        }
        try! onDebuggingDataAvailable.invokeHandlers(renderObjectTreeRenderer.debuggingData)
    }

    // TODO: maybe this little piece of rendering logic belongs into the App as well? / Maybe return a render object tree as well???? 
    // TODO: --> A Game scene could also be a render object with custom logic which is redrawn on every frame by render strategy.
    open func render(renderer: Renderer) throws {
        //try renderer.clipArea(bounds: globalBounds)
        if renderTreeInvalidated {
            print("CALLING FROM HERE", renderTreeInvalidated)
            if invalidatedWidgets.count > 0 {
                for widget in invalidatedWidgets.values {
                    updateRenderObjectTree(widget)
                }
                invalidatedWidgets.removeAll()
            } else {
                updateRenderObjectTree()
            }
            renderTreeInvalidated = false
        }
        try renderObjectTreeRenderer.render(with: renderer, in: bounds)
    }
}