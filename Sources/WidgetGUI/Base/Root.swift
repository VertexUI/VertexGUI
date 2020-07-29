import VisualAppBase
import CustomGraphicsMath
import Dispatch

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

    //private var widgetRenderObjectTreeGenerator = WidgetRenderObjectTreeGenerator()
    private var renderObjectTreeRenderer: RenderObjectTreeRenderer
    private var renderObjectTree: RenderObjectTree
    //private var renderTreeInvalidated = false
    //private var invalidatedWidgets = [UInt: Widget]()
    
    private var mouseEventManager = WidgetTreeMouseEventManager()

    public var onDebuggingDataAvailable = EventHandlerManager<RenderObjectTreeRenderer.DebuggingData>()

    public init(rootWidget contentRootWidget: Widget) {
        self.rootWidget = ThemeProvider {
            contentRootWidget
        }
        //super.init()
        self.renderObjectTree = RenderObjectTree()
        self.renderObjectTreeRenderer = RenderObjectTreeRenderer(renderObjectTree)
        self.rootWidget.parent = self
        // TODO: maybe dangling closure
        _ = self.rootWidget.onRenderStateInvalidated {
            //self.renderTreeInvalidated = true
            self.updateRenderObjectTree($0)
            //self.invalidatedWidgets[$0.id] = $0
        }
    }

    open func layout() {
        self.rootWidget.constraints = BoxConstraints(minSize: DSize2.zero, maxSize: self.bounds.size)
        self.rootWidget.layout()
    }

    open func consumeMouseEvent(_ rawMouseEvent: RawMouseEvent) -> Bool {
        self.mouseEventManager.propagate(event: rawMouseEvent, through: self.rootWidget)
        return false
    }

    /// - Parameter widget: If a specific widget is passed only the sub tree that was created by the widget will be updated.
    open func updateRenderObjectTree(_ widget: Widget? = nil) {
        if renderObjectTree.children.count == 0 {
            // TODO: provide an insert action
            renderObjectTree.children.append(rootWidget.render())
            renderObjectTreeRenderer.refresh()
        } else {
            var updatedWidget = widget ?? rootWidget
            var updatedSubTree = updatedWidget.render()
            let update = renderObjectTree.replace(updatedSubTree)
            renderObjectTreeRenderer.processUpdate(update)
        }
        try! onDebuggingDataAvailable.invokeHandlers(renderObjectTreeRenderer.debuggingData)
    }

    // TODO: maybe this little piece of rendering logic belongs into the App as well? / Maybe return a render object tree as well???? 
    // TODO: --> A Game scene could also be a render object with custom logic which is redrawn on every frame by render strategy.
    open func render(renderer: Renderer) throws {
        try renderObjectTreeRenderer.render(with: renderer, in: bounds)
        //try renderer.clipArea(bounds: globalBounds)
        /*if renderTreeInvalidated {
            if invalidatedWidgets.count > 0 {
                for widget in invalidatedWidgets.values {
                    updateRenderObjectTree(widget)
                }
                invalidatedWidgets.removeAll()
            } else {
                updateRenderObjectTree()
            }
            renderTreeInvalidated = false
        }*/

    }
}