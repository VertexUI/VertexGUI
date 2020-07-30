import WidgetGUI
import CustomGraphicsMath
import VisualAppBase

open class Widget: Bounded, Parent, Child {
    open var id: UInt = UInt.random(in: 0..<UInt.max)

    open var _context: WidgetContext?
    open var context: WidgetContext? {
        // TODO: might cache _context
        get {
            if let context = _context {
                return context
            }
            if let parent = parent as? Widget {
                return parent.context
            }
            return nil
        }
        set {
            _context = newValue
        }
    }

    open var constraints: BoxConstraints? = nil

    public lazy var children: [Widget] = []

    public var onParentChanged = EventHandlerManager<Parent?>()
    public var onAnyParentChanged = EventHandlerManager<Parent?>()
    public var onRenderStateInvalidated = EventHandlerManager<Widget>()
    private var unregisterAnyParentChangedHandler: EventHandlerManager<Parent?>.UnregisterCallback?
    weak open var parent: Parent? = nil {
        willSet {
            // TODO: remove listeners on any parent when parent is removed
            if newValue == nil && unregisterAnyParentChangedHandler != nil {
                unregisterAnyParentChangedHandler!()
            }
        }

        didSet {
            try! onParentChanged.invokeHandlers(parent)
            try! onAnyParentChanged.invokeHandlers(parent)
            if parent != nil {
                if let childParent = parent as? Child {
                    unregisterAnyParentChangedHandler = childParent.onAnyParentChanged({
                        try! self.onAnyParentChanged.invokeHandlers($0)
                    })
                }
            }
        }
    }

    public internal(set) var destroyed: Bool = false
    public var mounted: Bool = false
    // TODO: maybe something better
    public var layoutable: Bool {
        mounted && constraints != nil && context != nil
    }

    // TODO: might need to create something like layoutBounds and renderBounds (area that is invalidated on rerender request --> could be more than layoutBounds and affect outside widgets (e.g. a drop shadow that is not included in layoutBounds))
    open var bounds: DRect = DRect(topLeft: DPoint2(0,0), size: DSize2(0,0)) {
        didSet {
            // TODO: maybe let the parent list for onUpdateBounds on it's children instead of calling the parent
            if oldValue != bounds {
                if let parent = self.parent {
                    //try! parent.relayout()
                }
            }
        }
    }

    open var globalBounds: DRect {
        get {
            return DRect(topLeft: globalPosition, size: bounds.size)
        }
    }
    
    open var globalPosition: DPoint2 {
        get {
            if parent != nil {
                return parent!.globalPosition + bounds.topLeft
            }
            return bounds.topLeft
        }
    }

    public init(children: [Widget] = []) {
        self.children = children
    }

    open func mount(parent: Parent) {
        self.parent = parent
        for child in children {
            mountChild(child)
        }
        mounted = true
    }

    public func mountChild(_ child: Widget) {
        _ = child.onRenderStateInvalidated {
            self.invalidateRenderState($0)
        }
        child.mount(parent: self)
    }

    open func layout() {
        fatalError("layout() not implemented.")
    }

    // TODO: how to name this?
    public func initiateDestruction() throws {
        for child in children {
            try child.initiateDestruction()
        }
        parent = nil
        try destroy()
        destroyed = true
    }

    open func destroy() throws {
    }

    open func findParent(_ condition: (_ parent: Parent) throws -> Bool) rethrows -> Parent? {
        var parent: Parent? = self.parent
        while parent != nil {
            if try condition(parent!) {
                return parent
            }
            if let currentParent = parent as? Widget {
                parent = currentParent.parent
            }
        } 
        return nil
    }

    open func parentOfType<T>(_ type: T.Type) -> T? {
        var parent: Parent? = self.parent
        while parent != nil {
            if let parent = parent! as? T {
                return parent
            }
            if let currentParent = parent! as? Child {
                parent = currentParent.parent
            } else {
                break
            }
        }
        return nil
    }

    // TODO: might need possibility to return all of type + a method that only returns first + in what order depth first / breadth first
    public func childOfType<W: Widget>(_ type: W.Type) -> W? {
        for child in children {
            if let child = child as? W {
                return child
            }
        }
        
        for child in children {
            if let result = child.childOfType(type) {
                return result
            }
        }

        return nil
    }

    /// This should trigger a rerender of the widget in the next frame.
    public func invalidateRenderState(_ widget: Widget? = nil) {
        if destroyed {
            return
        }
        let widget = widget ?? self
        try! onRenderStateInvalidated.invokeHandlers(widget)
    }

    /// Returns the result of renderContent() wrapped in an IdentifiedSubTreeRenderObject
    public func render() -> IdentifiedSubTreeRenderObject {
        return IdentifiedSubTreeRenderObject(id) {
            renderContent()
        }
    }

    /// Invoked by render(), if Widget has children, should use child.render() to render them.
    open func renderContent() -> RenderObject? {
        .Container {
            children.map { $0.render() }
        }
    }
}

