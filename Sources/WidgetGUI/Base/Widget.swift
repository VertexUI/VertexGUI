import WidgetGUI
import CustomGraphicsMath
import VisualAppBase

open class Widget: Bounded, Parent, Child {
    public struct ReplacementContext {
        public var previousWidget: Widget?
        public var keyedWidgets: [String: Widget]
    }

    open var id: UInt = UInt.random(in: 0..<UInt.max)
    open var key: String?

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

    public internal(set) var onParentChanged = EventHandlerManager<Parent?>()
    public internal(set) var onAnyParentChanged = EventHandlerManager<Parent?>()
    public internal(set) var onRenderStateInvalidated = EventHandlerManager<Widget>()
    public internal(set) var onBoundsChanged = EventHandlerManager<DRect>()
    public internal(set) var onFocusChanged = EventHandlerManager<Bool>()
    public internal(set) var onDestroy = EventHandlerManager<Void>()
    
    private var unregisterAnyParentChangedHandler: EventHandlerManager<Parent?>.UnregisterCallback?

    weak open var parent: Parent? = nil {
        willSet {
            if unregisterAnyParentChangedHandler != nil {
                unregisterAnyParentChangedHandler!()
            }
        }

        didSet {
            onParentChanged.invokeHandlers(parent)
            onAnyParentChanged.invokeHandlers(parent)
            if parent != nil {
                if let childParent: Child = parent as? Child {
                    unregisterAnyParentChangedHandler = childParent.onAnyParentChanged({ [unowned self] in
                        onAnyParentChanged.invokeHandlers($0)
                    })
                }
            }
        }
    }

    public var focusable = false
    public internal(set) var focused = false {
        didSet {
            onFocusChanged.invokeHandlers(focused)
        }
    }

    public var mounted = false
    // TODO: maybe something better
    public var layoutable: Bool {
        mounted && constraints != nil && context != nil
    }
    public var layouted = false
    public internal(set) var destroyed = false

    //private var unregisterFunctions = [() -> ()]()

    // TODO: might need to create something like layoutBounds and renderBounds (area that is invalidated on rerender request --> could be more than layoutBounds and affect outside widgets (e.g. a drop shadow that is not included in layoutBounds))
    open var bounds: DRect = DRect(min: DPoint2(0,0), size: DSize2(0,0)) {
        didSet {
            // TODO: maybe let the parent list for onUpdateBounds on it's children instead of calling the parent
            if oldValue != bounds {
                if mounted && layouted && !destroyed {
                    onBoundsChanged.invokeHandlers(bounds)
                //if let parent = self.parent {
                    //try! parent.relayout()
                //}
                    invalidateRenderState()
                    //print("BOUNDS UPDATED", self)
                }
            }
        }
    }

    open var globalBounds: DRect {
        get {
            return DRect(min: globalPosition, size: bounds.size)
        }
    }
    
    open var globalPosition: DPoint2 {
        get {
            if parent != nil {
                return parent!.globalPosition + bounds.min
            }
            return bounds.min
        }
    }

    public init(children: [Widget] = []) {
        self.children = children
    }

    deinit {
        //print("Deinitialized Widget:", id, self)
    }

    public final func keyed(_ key: String) -> Self {
        self.key = key
        return self
    }

    /*/// Record unregister functions for handlers that were added to some handler list during the lifetime
    /// of the widget. The unregister functions will be called during destroy().
    public func autoClean(_ unregister: @escaping () -> ()) {
        unregisterFunctions.append(unregister)
    }*/

    public final func mount(parent: Parent, with context: ReplacementContext? = nil) {
        var oldSelf: Widget? = context?.previousWidget
        if
            let context = context {
                if let newKey = self.key {
                    oldSelf = context.keyedWidgets[newKey]
                }

                if let newSelf = self as? (Widget & AnyStatefulWidget), let oldSelf = oldSelf as? (Widget & AnyStatefulWidget) {
                
                    var attemptStateReplace = false

                    if 
                        let newKey = newSelf.key,
                        let oldKey = oldSelf.key,
                        oldKey == newKey {
                            attemptStateReplace = true
                    } else if newSelf.key == nil, oldSelf.key == nil {
                        attemptStateReplace = true
                    }

                    if attemptStateReplace && type(of: newSelf) == type(of: oldSelf) {
                        newSelf.anyState = oldSelf.anyState
                    }
                }
        }
    
        self.parent = parent
 
        build()
 
        for i in 0..<children.count {
            let oldChild: Widget?
            if let oldSelf = oldSelf {
                oldChild = oldSelf.children.count > i ? oldSelf.children[i] : nil
            } else {
                oldChild = nil
            }
            let childContext = oldChild == nil && context == nil ? nil : ReplacementContext(
                previousWidget: oldChild, keyedWidgets: context?.keyedWidgets ?? [:])
            mountChild(children[i], with: childContext)
        }
        mounted = true
    }

    /// Called automatically during mount(). Can be used to fill self.children.
    // TODO: maybe rename to inMount or something like that
    open func build() {

    }

    public final func mountChild(_ child: Widget, with context: ReplacementContext? = nil) {
        _ = child.onRenderStateInvalidated { [unowned self] in
            invalidateRenderState($0)
        }
        // TODO: buffer updates over a certain timespan and then relayout
        _ = child.onBoundsChanged { [unowned self] _ in
            layout()
        }
        child.mount(parent: self, with: context)
    }

    // TODO: this function might be better suited to parent
    public func replaceChildren(with newChildren: [Widget]) {
        let oldChildren = children

        var keyedChildren: [String: Widget] = [:]

        var checkChildren: [Widget] = oldChildren
        while let child = checkChildren.popLast() {
            if let key = child.key {
                keyedChildren[key] = child
            }
            checkChildren.append(contentsOf: child.children)
        }

        children = newChildren
        
        for i in 0..<children.count {
            let newChild = children[i]
            let oldChild: Widget? = oldChildren.count > i ? oldChildren[i] : nil
            let childContext = ReplacementContext(previousWidget: oldChild, keyedWidgets: keyedChildren)
            mountChild(newChild, with: childContext)
        }

        for child in oldChildren {
            child.destroy()
        }
    }

    open func performLayout() {
        fatalError("performLayout() not implemented.")
    }
        
    public final func layout() {
        if !layoutable {
            print("Warning: called layout() on Widget that is not layoutable:", self)
            return
        }
        performLayout()
        layouted = true
    }

    // TODO: how to name this?
    public final func destroy() {
        for child in children {
            child.destroy()
        }
        mounted = false
        onParentChanged.removeAllHandlers()
        onAnyParentChanged.removeAllHandlers()
        onRenderStateInvalidated.removeAllHandlers()
        parent = nil
        destroySelf()
        onDestroy.invokeHandlers(Void())
        destroyed = true
        //print("Destroyed Widget:", id, self)
    }

    open func destroySelf() {
    }

    public func requestFocus() {
        if focusable {
            if context!.requestFocus(self) {
                focused = true
            }
        }
    }

    public func dropFocus() {
        if focusable {
            focused = false
        }
    }

    public final func findParent(_ condition: (_ parent: Parent) throws -> Bool) rethrows -> Parent? {
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

    public final func parentOfType<T>(_ type: T.Type) -> T? {
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
    public final func childOfType<W: Widget>(_ type: W.Type) -> W? {
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
    public final func invalidateRenderState(_ widget: Widget? = nil) {
        if destroyed {
            print("Warning: Tried to call invalidateRenderState() on destroyed widget: \(self)")
            return
        }
        if !mounted {
            print("Warning: Called invalidateRenderState() on an unmounted Widget:", self)
            return
        }
        let widget = widget ?? self
        try! onRenderStateInvalidated.invokeHandlers(widget)
    }

    public final func invalidateRenderState(after block: () -> ()) {
        block()
        invalidateRenderState()
    }

    /// Returns the result of renderContent() wrapped in an IdentifiedSubTreeRenderObject
    public final func render() -> IdentifiedSubTreeRenderObject {
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

