import Foundation
import CustomGraphicsMath
import VisualAppBase
import ColorizeSwift

open class Widget: Bounded, Parent, Child {
    public struct ReplacementContext {
        public var previousWidget: Widget?
        public var keyedWidgets: [String: Widget]
    }

    open var id: UInt = UInt.random(in: 0..<UInt.max)
    open var key: String?
    open var classes: [String] = []

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

    @available(*, deprecated, message: "Constraints is now passed as a parameter to layout(constraints:)")
    open var constraints: BoxConstraints? = nil

    public lazy var children: [Widget] = []

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

    lazy open internal(set) var boxConfig = getBoxConfig() {
        didSet {
            // either the own preferred size or a position or size of a child
            // or any other layout important value has changed, so the layout can't be valid anymore
            // setting this flag will force a relayout, even if the passed constraints
            // are the same on the next layout cycle
            layoutInvalid = true
        }
    }

    /// bridge boxConfig for use in @inlinable functions
    @usableFromInline internal var _boxConfig: BoxConfig {
        get {
            boxConfig
        }

        set {
            boxConfig = newValue
        }
    }

    open private(set) var size = DSize2(0, 0) {
        didSet {
            if oldValue != size {
                if mounted && layouted && !layouting && !destroyed {
                    onSizeChanged.invokeHandlers(size)
                    invalidateRenderState()
                }
            }
        }
    }

    open var width: Double {
        size.width
    }

    open var height: Double {
        size.height
    }
    
    open var position = DPoint2(0, 0) {
        didSet {
            invalidateRenderState(deep: true)
        }
    }

    @inlinable open var x: Double {
        get {
            position.x
        }
        
        set {
            position.x = newValue
        }
    }

    @inlinable open var y: Double {
        get {
            position.y
        }
        
        set {
            position.y = newValue
        }
    }
    
    // TODO: might need to create something like layoutBounds and renderBounds (area that is invalidated on rerender request --> could be more than layoutBounds and affect outside widgets (e.g. a drop shadow that is not included in layoutBounds))
    // TODO: make size unsettable from outside when new layout approach completed
    @inlinable open var bounds: DRect {
        DRect(min: position, size: size)
    }
    
    @inlinable open var globalBounds: DRect {
        return DRect(min: globalPosition, size: bounds.size)
    }
    
    @inlinable open var globalPosition: DPoint2 {
        if parent != nil {
            return parent!.globalPosition + bounds.min
        }
        return bounds.min
    }

    public internal(set) var previousConstraints: BoxConstraints?
 
    public internal(set) var focusable = false
    public internal(set) var focused = false {
        didSet {
            onFocusChanged.invokeHandlers(focused)
        }
    }
    /// bridge focused property for use in @inlinable functions
    @usableFromInline internal var _focused: Bool {
        get {
            return focused
        }

        set {
            focused = newValue
        }
    }

    public private(set) var mounted = false
    // TODO: maybe something better
    public var layoutable: Bool {
        mounted/* && constraints != nil*/ && context != nil
    }
    public private(set) var layouting = false
    public private(set) var layouted = false
    // TODO: maybe rename to boundsInvalid???
    public internal(set) var layoutInvalid = true
    public internal(set) var destroyed = false



    @usableFromInline internal var reference: ReferenceProtocol? {
        didSet {
            if var reference = reference {
                reference.referenced = self
            }
        }
    }

    @usableFromInline internal var renderState = RenderState()

    /// Flag whether to show bounds and sizes for debugging purposes.
    private var _debugLayout: Bool?
    public var debugLayout: Bool {
        get {
            _debugLayout ?? context?.debugLayout ?? false
        }

        set {
            _debugLayout = newValue
        }
    }
    public var layoutDebuggingColor = Color.Red
    private let layoutDebuggingTextFontConfig = FontConfig(family: defaultFontFamily, size: 16, weight: .Regular, style: .Normal)

    public var countCalls: Bool = true
    @usableFromInline lazy internal var callCounter = CallCounter(widget: self)


    public internal(set) var onParentChanged = EventHandlerManager<Parent?>()
    public internal(set) var onAnyParentChanged = EventHandlerManager<Parent?>()
    public internal(set) var onMounted = EventHandlerManager<Void>()
    public internal(set) var onBoxConfigChanged = EventHandlerManager<BoxConfigChangedEvent>()
    public internal(set) var onSizeChanged = EventHandlerManager<DSize2>()
    public internal(set) var onLayoutInvalidated = EventHandlerManager<Void>()
    /// Forwards LayoutInvalidated Events up from children (recursive). Also emits own events.
    public internal(set) var onAnyLayoutInvalidated = EventHandlerManager<Widget>()
    public internal(set) var onLayoutingStarted = EventHandlerManager<BoxConstraints>()
    public internal(set) var onLayoutingFinished = EventHandlerManager<DSize2>()
    public internal(set) var onRenderStateInvalidated = EventHandlerManager<Widget>()
    public internal(set) var onAnyRenderStateInvalidated = EventHandlerManager<Widget>()
    // TODO: this could lead to a strong reference cycle
    public internal(set) var onFocusChanged = WidgetEventHandlerManager<Bool>()
    public internal(set) var onDestroy = EventHandlerManager<Void>()
    
    private var unregisterAnyParentChangedHandler: EventHandlerManager<Parent?>.UnregisterCallback?
			    
    public init(children: [Widget] = []) {
        self.children = children
        setupWidgetEventHandlerManagers()
    }

    private func setupWidgetEventHandlerManagers() {
        let mirror = Mirror(reflecting: self)
        for child in mirror.allChildren {
            if var manager = child.value as? AnyWidgetEventHandlerManager {
                manager.widget = self
            }
        }
    }

    deinit {
        Logger.log("Deinitialized Widget: \(id) \(self)", level: .Message, context: .Default)
    }

    // TODO: maybe find better names for the following functions?

    @inlinable public final func with(key: String) -> Self {
        self.key = key
        return self
    }

    @inlinable public final func connect(ref reference: ReferenceProtocol) -> Self {
        self.reference = reference
        return self
    }    

    @inlinable public final func with(block: (Self) -> ()) -> Self {
        block(self)
        return self
    }
 
    public final func mount(parent: Parent, with context: ReplacementContext? = nil) {
        var oldSelf: Widget? = context?.previousWidget
        if let context = context {
            if let newKey = self.key {
                oldSelf = context.keyedWidgets[newKey]
            }

            if let newSelf = self as? (Widget & AnyStatefulWidget), let oldSelf = oldSelf as? (Widget & AnyStatefulWidget) {
                var attemptStateReplace = false

                if  let newKey = newSelf.key,
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

        resolveDependencies()

        addedToParent()

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

        onMounted.invokeHandlers(Void())
    }

    private final func resolveDependencies() {

        var injectables = [AnyInject]()
        
        let mirror = Mirror(reflecting: self)
        
        for child in mirror.children {
            
            // TODO: this type of value needs to be caught specifically for some reason or there will be a crash
            if child.value is [AnyObject] {

                continue
            }

            if child.value is AnyInject {

                injectables.append(child.value as! AnyInject)
            }
        }

        if injectables.count > 0 {
            
            let providers = getParents(ofType: DependencyProvider.self)

            for provider in providers {
                
                for injectable in injectables {

                    if injectable.anyValue == nil {
                        
                        if let dependency = provider.getDependency(ofType: injectable.anyType) {

                            injectable.anyValue = dependency.value
                        }
                    }
                }
            }
        }
    }

    open func addedToParent() {

    }

    /// Called automatically during mount(). Can be used to fill self.children.
    // TODO: maybe rename to inMount or something like that
    open func build() {

    }

    public final func mountChild(_ child: Widget, with context: ReplacementContext? = nil) {

        child.mount(parent: self, with: context)

        _ = child.onBoxConfigChanged { [unowned self, unowned child] _ in
            
            handleChildBoxConfigChanged(child: child)
        }

        _ = child.onSizeChanged { [unowned self, unowned child] _ in
            // TODO: maybe need special relayout flag / function

            Logger.log("Size of child \(child) of parent \(self) changed.".with(fg: .Blue, style: .Bold), level: .Message, context: .WidgetLayouting)

            if layouted && !layouting {

                Logger.log("Performing layout on parent parent.", level: .Message, context: .WidgetLayouting)
                
                invalidateLayout()
            }
        }
        
        _ = child.onAnyLayoutInvalidated { [unowned self] in
            
            onAnyLayoutInvalidated.invokeHandlers($0)
        }
        
        _ = child.onAnyRenderStateInvalidated { [unowned self] in

            onAnyRenderStateInvalidated.invokeHandlers($0)
        }

        _ = child.onFocusChanged { [unowned self] in

            focused = $0
        }
    }

    private final func handleChildBoxConfigChanged(child: Widget) {

        Logger.log("Box config of child: \(child) of parent \(self) changed.".with(fg: .Blue, style: .Bold), level: .Message, context: .WidgetLayouting)

        if layouted && !layouting {

            Logger.log("Invalidating own box config.", level: .Message, context: .WidgetLayouting)

            let oldBoxConfig = boxConfig

            invalidateBoxConfig()

            let newBoxConfig = boxConfig

            // This prevents unnecessary calls to layout.
            // Only if this Widgets box config isn't changed, trigger a relayout.
            // For all children with changed box configs (also deeply nested ones)
            // layout will not have been called because of this comparison.
            // The first parent without a changed box config will trigger
            // a relayout for the whole subtree.
            // In case no Widget has no changed box config, the
            // relayout will be triggered in Root for the whole UI.
            // TODO: maybe there is a better solution
            if oldBoxConfig == newBoxConfig {

                Logger.log("Own box config is changed. Perform layout with previous constraints: \(String(describing: previousConstraints))".with(fg: .Yellow), level: .Message, context: .WidgetLayouting)
                
                invalidateLayout()
            }
        }
    }

    // TODO: this function might be better suited to parent
    public final func replaceChildren(with newChildren: [Widget]) {

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

        invalidateLayout()

        invalidateRenderState()
    }

    open func getBoxConfig() -> BoxConfig {

        fatalError("getBoxConfig() not implemented for Widget \(self).")
    }

    // TODO: maybe call this updateBoxConfig / or queueBoxConfigUpdate??? --> on next tick?
    @inlinable public final func invalidateBoxConfig() {
        
        let currentBoxConfig = boxConfig

        let newBoxConfig = getBoxConfig()

        if currentBoxConfig != newBoxConfig {

            _boxConfig = newBoxConfig

            onBoxConfigChanged.invokeHandlers(BoxConfigChangedEvent(old: currentBoxConfig, new: newBoxConfig))
        }
    }

    @inlinable public final func layout(constraints: BoxConstraints) {

        #if DEBUG
        
        Logger.log("Attempting layout".with(fg: .Yellow), "on Widget: \(self).", level: .Message, context: .WidgetLayouting)

        #endif

        if !layoutInvalid, let previousConstraints = previousConstraints, constraints == previousConstraints {
            
            #if DEBUG

            Logger.log("Constraints equal pervious constraints and layout is not invalid.", "Not performing layout.".with(fg: .Yellow), level: .Message, context: .WidgetLayouting)
            
            #endif

            return
        }
        
        if !layoutable {

            #if DEBUG
            
            Logger.warn("Called layout() on Widget that is not layoutable: \(self)", context: .WidgetLayouting)

            #endif

            return
        }

        if layouting {

            #if DEBUG
            
            Logger.warn("Called layout() on Widget while that Widget was still layouting: \(self)", context: .WidgetLayouting)

            #endif

            return
        }

        _layout(constraints: constraints)
    }

    @usableFromInline internal final func _layout(constraints: BoxConstraints) {

        if constraints.minWidth.isInfinite || constraints.minHeight.isInfinite {

            fatalError("Widget received constraints that contain infinite value in min size: \(self)")
        }

        #if (DEBUG)

        if countCalls {

            callCounter.count(.Layout)
        }

        Logger.log("Layouting Widget: \(self)".with(fg: .Blue, style: .Bold), level: .Message, context: .WidgetLayouting)

        Logger.log("Constraints: \(constraints)", level: .Message, context: .WidgetLayouting)
        
        Logger.log("Current size: \(bounds.size)", level: .Message, context: .WidgetLayouting)

        #endif

        layouting = true

        onLayoutingStarted.invokeHandlers(constraints)

        let previousSize = size

        let isFirstRound = !layouted

        let startTimestamp = Date.timeIntervalSinceReferenceDate

        let newUnconstrainedSize = performLayout(constraints: constraints)

        let layoutDuration = Date.timeIntervalSinceReferenceDate - startTimestamp

        #if DEBUG

        Logger.log("Layout of Widget: \(self) took time:", (layoutDuration.description + " s").with(style: .Bold), level: .Message, context: .WidgetLayouting)

        Logger.log("Layout of Widget: \(self) produced result.".with(fg: .Green, style: .Bold), level: .Message, context: .WidgetLayouting)

        Logger.log("New self size: \(newUnconstrainedSize)", level: .Message, context: .WidgetLayouting)

        #endif

        let constrainedSize = constraints.constrain(newUnconstrainedSize)

        #if DEBUG

        if newUnconstrainedSize != constrainedSize {

            Logger.warn("New size does not respect constraints. Size: \(newUnconstrainedSize), Constraints: \(constraints)", context: .WidgetLayouting)
        }

        #endif

        let boxConfigConstrainedSize = BoxConstraints(

            minSize: boxConfig.minSize,

            maxSize: boxConfig.maxSize)

                .constrain(newUnconstrainedSize)
        
        if newUnconstrainedSize != boxConfigConstrainedSize {

            Logger.warn("New size does not respect own box config. Size: \(newUnconstrainedSize), BoxConfig: \(boxConfig)")
        }

        size = constrainedSize

        layouting = false

        layouted = true

        layoutInvalid = false

        // TODO: where to call this? after setting bounds or before?
        onLayoutingFinished.invokeHandlers(bounds.size)

        if previousSize != size && !isFirstRound {

            Logger.log("Size changed and is not first round.".with(fg: .Yellow), level: .Message, context: .WidgetLayouting)

            onSizeChanged.invokeHandlers(size)

            invalidateRenderState()
        }

        self.previousConstraints = constraints
    }

    @inlinable public final func invalidateLayout() {
 
        if layoutInvalid {
            
            #if DEBUG

            Logger.warn("Called invalidateLayout() on a Widget where layout is already invalid: \(self)", context: .WidgetLayouting)

            #endif

            return
        }

        _invalidateLayout()
    }

    @usableFromInline
    internal final func _invalidateLayout() {
        #if (DEBUG)
        if countCalls {
            callCounter.count(.InvalidateLayout)
        }
        #endif
        layoutInvalid = true
        onLayoutInvalidated.invokeHandlers(Void())
        onAnyLayoutInvalidated.invokeHandlers(self)
    }

    open func performLayout(constraints: BoxConstraints) -> DSize2 {
        fatalError("performLayout(constraints:) not implemented.")
    }

    @discardableResult
    open func requestFocus() -> Self {
        if focusable {
            // TODO: maybe run requestfocus and let the context notify the focused widget of receiving focus?
            if mounted {
                if context!.requestFocus(self) {
                    _focused = true
                }
            } else {
                onMounted.once { [unowned self] in
                    if context!.requestFocus(self) {
                        _focused = true
                    }
                }
            }
        }
        return self
    }

    @inlinable
    public func dropFocus() {
        if focusable {
            _focused = false
        }
    }

    /// Returns the result of renderContent() wrapped in an IdentifiedSubTreeRenderObject
    @inlinable
    public final func render() -> RenderObject.IdentifiedSubTree {
        if renderState.invalid {
            #if (DEBUG)
            if countCalls {
                callCounter.count(.Render)
            }
            Logger.log("Render state of Widget: \(self) invalid. Rerendering.".with(fg: .Yellow), level: .Message, context: .WidgetRendering)
            #endif

            updateRenderState()
        } else {
            #if DEBUG
            Logger.log("Render state of Widget: \(self) valid. Using cached state.".with(fg: .Yellow), level: .Message, context: .WidgetRendering)
            #endif
        }

        return renderState.content!
    }

    @usableFromInline internal final func updateRenderState() {

        if !renderState.invalid {

            #if DEBUG

            Logger.warn("Called updateRenderState on Widget where renderState is not invalid.".with(fg: .White, bg: .Red), context: .WidgetRendering)

            #endif

            return
        }

        let subTree = renderState.content ?? IdentifiedSubTreeRenderObject(id, [])

        if mounted && layouted && !layouting {

            subTree.removeChildren()

            if let content = renderContent() {

                subTree.appendChild(content)
            }

            if debugLayout {

                subTree.appendChild(renderLayoutDebuggingInformation())
            }

        } else {

            #if DEBUG
            
            Logger.warn("Called updateRenderState on Widget that cannot be rendered in it's current state.".with(fg: .White, bg: .Red), context: .WidgetRendering)

            #endif            
        }

        renderState.content = subTree

        renderState.invalid = false
    }

    /// Invoked by render(), if Widget has children, should use child.render() to render them.
    open func renderContent() -> RenderObject? {
        
        .Container {

            children.map { $0.render() }
        }
    }

    private final func renderLayoutDebuggingInformation() -> RenderObject {

        RenderObject.Container {

            RenderObject.RenderStyle(strokeWidth: 1, strokeColor: FixedRenderValue(layoutDebuggingColor)) {

                RenderObject.Rectangle(globalBounds)
            }

            RenderObject.Text(

                "\(bounds.size.width) x \(bounds.size.height)",

                fontConfig: layoutDebuggingTextFontConfig,

                color: layoutDebuggingColor,

                topLeft: globalBounds.min)
        }
    }

    /// This should trigger a rerender of the widget in the next frame.
    @inlinable public final func invalidateRenderState(deep: Bool = false) {
        if renderState.invalid {
            #if DEBUG
            Logger.warn("Called invalidateRenderState() when render state is already invalid on Widget: \(self)", context: .WidgetRendering)
            #endif
            return
        }

        if destroyed {
            #if DEBUG
            Logger.warn("Tried to call invalidateRenderState() on destroyed widget: \(self)", context: .WidgetRendering)
            #endif
            return
        }

        if !mounted {
            #if DEBUG
            Logger.warn("Called invalidateRenderState() on an unmounted Widget: \(self)", context: .WidgetRendering)
            #endif
            return
        }

        _invalidateRenderState(deep: deep)
    }

    @inlinable public final func invalidateRenderState(deep: Bool = false, after block: () -> ()) {
        block()
        invalidateRenderState(deep: deep)
    }

    @usableFromInline internal final func _invalidateRenderState(deep: Bool) {
        #if (DEBUG)
        if countCalls {
            callCounter.count(.InvalidateRenderState)
        }
        #endif
        if deep {
            for child in children {
                child.invalidateRenderState(deep: true)
            }
        }
        renderState.invalid = true
        onRenderStateInvalidated.invokeHandlers(self)
        onAnyRenderStateInvalidated.invokeHandlers(self)
    }

    // TODO: how to name this?
    public final func destroy() {
        for child in children {
            child.destroy()
        }

        mounted = false

        if var reference = reference {

            reference.referenced = nil
        }

        // TODO: maybe automatically clear all EventHandlerManagers / WidgetEventHandlerManagers by using reflection?

        onParentChanged.removeAllHandlers()

        onAnyParentChanged.removeAllHandlers()

        onMounted.removeAllHandlers()

        onBoxConfigChanged.removeAllHandlers()
                
        onSizeChanged.removeAllHandlers()
        
        onLayoutInvalidated.removeAllHandlers()
        
        onAnyLayoutInvalidated.removeAllHandlers()
        
        onLayoutingStarted.removeAllHandlers()

        onLayoutingFinished.removeAllHandlers()

        onRenderStateInvalidated.removeAllHandlers()

        onAnyRenderStateInvalidated.removeAllHandlers()
        
        let mirror = Mirror(reflecting: self)
        for child in mirror.allChildren {
            if var manager = child.value as? AnyWidgetEventHandlerManager {
                manager.removeAllHandlers()
                manager.widget = nil
            }
        } 

        parent = nil

        destroySelf()

        onDestroy.invokeHandlers(Void())

        destroyed = true

        Logger.log("Destroyed Widget: \(self), \(id)", level: .Message, context: .Default)
    }

    open func destroySelf() {}
}

extension Widget {
    public struct BoxConfigChangedEvent {
        public var old: BoxConfig
        public var new: BoxConfig
        public init(old: BoxConfig, new: BoxConfig) {
            self.old = old
            self.new = new
        }
    }
}