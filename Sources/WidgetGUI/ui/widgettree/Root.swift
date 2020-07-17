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
            renderTreeInvalidated = true
        }
    }

    open var globalPosition: DPoint2 {
        get {
            return bounds.topLeft
        }
    }

    public var rootWidget: Widget
    /*public var mouseEventConsumers: [MouseEventConsumer] {
        get {
            return [rootWidget]
        }
        set {}
    }*/

    private var renderObjectRenderer = RenderTreeRenderer()
    private var renderTree: RenderTree?
    private var renderTreeInvalidated = false
    
    private var mouseEventPropagationStrategy = GUIMouseEventPropagationStrategy()

    public init(rootWidget: Widget) {
        self.rootWidget = rootWidget
        //super.init()
        rootWidget.parent = self
        // TODO: maybe dangling closure
        _ = rootWidget.onRenderStateInvalidated {
            self.renderTreeInvalidated = true
        }
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
    open func consumeMouseEvent(_ rawMouseEvent: RawMouseEvent) -> Bool {
        return mouseEventPropagationStrategy.propagate(event: rawMouseEvent, through: rootWidget)
    }

    open func updateRenderTree() {
        // TODO: do something with subtrees, etc., maybe, maybe just traverse and check whether can reuse some things
        renderTree = RenderTree([rootWidget.render()!])
        renderObjectRenderer.updateRenderTree(renderTree!)
    }

    // TODO: maybe this little piece of rendering logic belongs into the App as well? / Maybe return a render object as well???? 
    // TODO: --> A Game scene could also be a render object with custom logic which is redrawn on every frame by render strategy.
    open func render(renderer: Renderer) throws {
        //try renderer.clipArea(bounds: globalBounds)
        if renderTree == nil || renderTreeInvalidated {
            updateRenderTree()
        }
        //var renderObject = try rootWidget.render()
        //renderObjectRenderer.updateRenderTree(renderTree!)
        try renderObjectRenderer.renderGroups(renderer)
        //try renderer.releaseClipArea()
    }
}