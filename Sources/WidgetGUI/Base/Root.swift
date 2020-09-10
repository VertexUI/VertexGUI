import VisualAppBase
import CustomGraphicsMath
import Dispatch

open class Root: Parent {

    open var context: WidgetContext? {

        didSet {
            
            if let context = context {

                context.debugLayout = debugLayout
            }

            rootWidget.context = context
        }
    }
    
    open var bounds: DRect = DRect(min: DPoint2(0,0), size: DSize2(0,0)) {

        didSet {

            rootWidget.invalidateRenderState()

            layout()

            updateRenderObjectTree()
        }
    }

    open var globalPosition: DPoint2 {

        get {

            return bounds.min
        }
    }

    public var rootWidget: Widget

    private var renderObjectTreeRenderer: RenderObjectTreeRenderer
    
    private var renderObjectTree: RenderObjectTree

    private var rerenderWidgets: [Widget] = []
    
    private var mouseEventManager = WidgetTreeMouseEventManager()

    public var debugLayout = false {

        didSet {

            if let context = context {

                context.debugLayout = debugLayout
            }
        }
    }

    public var onDebuggingDataAvailable = ThrowingEventHandlerManager<RenderObjectTreeRenderer.DebuggingData>()

    public init(rootWidget contentRootWidget: Widget) {

        rootWidget = contentRootWidget
        
        renderObjectTree = RenderObjectTree()
        
        renderObjectTreeRenderer = RenderObjectTreeRenderer(renderObjectTree)
        
        rootWidget.mount(parent: self)

        /*_ = rootWidget.onRenderStateInvalidated { [unowned self] in

            updateRenderObjectTree($0)
        }*/

        _ = rootWidget.onBoxConfigChanged { [unowned self] _ in

            layout()
        }

        _ = rootWidget.onAnyRenderStateInvalidated { [unowned self] in

            rerenderWidgets.append($0)
        }
    }

    open func layout() {

        rootWidget.layout(constraints: BoxConstraints(minSize: bounds.size, maxSize: bounds.size))
    }

    @discardableResult open func consume(_ rawMouseEvent: RawMouseEvent) -> Bool {

        _ = self.mouseEventManager.propagate(event: rawMouseEvent, through: self.rootWidget)

        return false
    }

    @discardableResult open func consume(_ rawKeyEvent: KeyEvent) -> Bool {
        
        propagate(rawKeyEvent)

        return false
    }

    @discardableResult open func consume(_ rawTextEvent: TextEvent) -> Bool {

        propagate(rawTextEvent)

        return false
    }

    /// - Parameter widget: If a specific widget is passed only the sub tree that was created by the widget will be updated.
    open func updateRenderObjectTree(_ widget: Widget? = nil) {

        if renderObjectTree.children.count == 0 {

            // TODO: provide an insert function
            renderObjectTree.children.append(rootWidget.render())

            renderObjectTreeRenderer.refresh()

        } else {

            var updatedWidget = widget ?? rootWidget

            var updatedSubTree = updatedWidget.render()

            if let update = renderObjectTree.replace(updatedSubTree) {

                renderObjectTreeRenderer.processUpdate(update)
            }
        }

        try! onDebuggingDataAvailable.invokeHandlers(renderObjectTreeRenderer.debuggingData)
    }

    // TODO: maybe this little piece of rendering logic belongs into the App as well? / Maybe return a render object tree as well???? 
    // TODO: --> A Game scene could also be a render object with custom logic which is redrawn on every frame by render strategy.
    open func render(with renderer: Renderer) {
        
        for widget in rerenderWidgets {
            
            widget.updateRenderState()
        }

        rerenderWidgets = []

        try! renderObjectTreeRenderer.render(with: renderer, in: bounds)
    }

    open func destroy() {

        rootWidget.destroy()
    }
}