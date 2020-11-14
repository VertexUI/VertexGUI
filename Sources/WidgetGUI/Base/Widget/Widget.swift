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
    open var visibility: Visibility = .Visible {
        didSet {
            if oldValue != visibility {
                // TODO: should invalidation of lifecycle happen inside didSet?
                invalidateRenderState()
            }
        }
    }

    open var _context: WidgetContext?
    open var context: WidgetContext {
        // TODO: might cache _context
        get {
            if let context = _context {
                return context
            }

            if let parent = parent as? Widget {
                return parent.context
            }
            
            fatalError("tried to access context when it was not yet available")
        }

        set {
            _context = newValue
        }
    }
    private var contextOnTickHandlerRemover: (() -> ())? = nil

    @usableFromInline
    internal var inspectionBus: WidgetBus<WidgetInspectionMessage> {
        context.inspectionBus
    }

    public internal(set) var lifecycleBus = WidgetBus<WidgetLifecycleMessage>()

    /*private var _focusContext: FocusContext?
    open var focusContext: FocusContext {
        get {
            _focusContext!
        }

        set {
            _focusContext = newValue
            for child in children {
                child.focusContext = newValue
            }
        }
    }*/

    @available(*, deprecated, message: "Constraints is now passed as a parameter to layout(constraints:)")
    open var constraints: BoxConstraints? = nil

    public lazy var children: [Widget] = []

    weak open var parent: Parent? = nil {
        willSet {
            if unregisterAnyParentChangedHandler != nil {
                unregisterAnyParentChangedHandler!()
            }
        }

        /*didSet {
            onParentChanged.invokeHandlers(parent)
            onAnyParentChanged.invokeHandlers(parent)
            if parent != nil {
                if let childParent: Child = parent as? Child {
                    unregisterAnyParentChangedHandler = childParent.onAnyParentChanged({ [unowned self] in
                        onAnyParentChanged.invokeHandlers($0)
                    })
                }
            }
        }*/
    }

    lazy open internal(set) var boxConfig = getBoxConfig()

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
    public var buildInvalid = false
    public var boxConfigInvalid = false
    public private(set) var layouting = false
    public private(set) var layouted = false
    // TODO: maybe rename to boundsInvalid???
    public internal(set) var layoutInvalid = false
    public internal(set) var destroyed = false



    @usableFromInline internal var reference: AnyReferenceProtocol? {
        didSet {
            if var reference = reference {
                reference.anyReferenced = self
            }
        }
    }

    @usableFromInline internal var renderState = RenderState()

    /// Flag whether to show bounds and sizes for debugging purposes.
    //@MutableProperty
    ////internal var _debugLayout: Bool?
    @MutableProperty
    public var debugLayout: Bool = false/* {
        get {
            _debugLayout ?? context.debugLayout
        }

        set {
            _debugLayout = newValue
        }
    }*/
    @MutableProperty
    public var layoutDebuggingColor = Color.Red
    private let layoutDebuggingTextFontConfig = FontConfig(family: defaultFontFamily, size: 16, weight: .Regular, style: .Normal)
    // if true, highlight the Widget when bursts of calls to functions such as layout or render occur
    public var burstHighlightEnabled = true
    @usableFromInline
    internal var highlighted = false

    public var countCalls: Bool = true
    @usableFromInline lazy internal var callCounter = CallCounter(widget: self)

    public internal(set) var onParentChanged = EventHandlerManager<Parent?>()
    public let onDependenciesInjected = WidgetEventHandlerManager<Void>()
    public internal(set) var onMounted = EventHandlerManager<Void>()
    public internal(set) var onTick = WidgetEventHandlerManager<Tick>()
    public internal(set) var onBoxConfigInvalidated = WidgetEventHandlerManager<Void>()
    public internal(set) var onBoxConfigChanged = EventHandlerManager<BoxConfigChangedEvent>()
    public internal(set) var onSizeChanged = EventHandlerManager<DSize2>()
    public internal(set) var onLayoutInvalidated = EventHandlerManager<Void>()
    public internal(set) var onLayoutingStarted = EventHandlerManager<BoxConstraints>()
    public internal(set) var onLayoutingFinished = EventHandlerManager<DSize2>()
    public internal(set) var onRenderStateInvalidated = EventHandlerManager<Widget>()
    public internal(set) var onFocusChanged = WidgetEventHandlerManager<Bool>()
    public internal(set) var onDestroy = EventHandlerManager<Void>()
    
    private var unregisterAnyParentChangedHandler: EventHandlerManager<Parent?>.UnregisterCallback?
			    
    public init(children: [Widget] = []) {
        self.children = children
        setupWidgetEventHandlerManagers()
        _ = onDestroy(_debugLayout.onChanged { [unowned self] _ in
            invalidateRenderState()
        })
        _ = onDestroy(_layoutDebuggingColor.onChanged { [unowned self] _ in
            invalidateRenderState()
        })
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
      if !destroyed {
        fatalError("Deinitialized Widget without calling destroy() first")
      }
      Logger.log("Deinitialized Widget: \(id) \(self)", level: .Message, context: .Default)
    }

    // TODO: maybe find better names for the following functions?

    @inlinable
    public final func with(key: String) -> Self {
        self.key = key
        return self
    }

    @inlinable
    public final func connect(ref reference: AnyReferenceProtocol) -> Self {
        self.reference = reference
        self.reference!.anyReferenced = self
        return self
    }

    @inlinable
    public final func with(block: (Self) -> ()) -> Self {
        block(self)
        return self
    }
 
    private final func setupContext() {
        contextOnTickHandlerRemover = context.onTick({ [weak self] in
          if let self = self {
            self.onTick.invokeHandlers($0)
          } else {
            print("THERE IS NO SELF IN ON TICK!")
          }
        })
    }
    
    private final func undoContextSetup() {
      if contextOnTickHandlerRemover == nil {
        fatalError("CALLED UNDOCONTEXTSETUP when remove handler is nil")
      }
      if let remove = contextOnTickHandlerRemover {
        remove()
      }
    }
    
    public final func mount(
        parent: Parent,
        context: WidgetContext,
        lifecycleBus: WidgetBus<WidgetLifecycleMessage>,
        with replacementContext: ReplacementContext? = nil) {
            self.context = context
            self.setupContext()
            self.lifecycleBus = lifecycleBus
            
                var oldSelf: Widget? = replacementContext?.previousWidget
                if let replacementContext = replacementContext {
                    if let newKey = self.key {
                        oldSelf = replacementContext.keyedWidgets[newKey]
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

                onDependenciesInjected.invokeHandlers(())

                addedToParent()

                build()
        
                mounted = true

                onMounted.invokeHandlers(Void())
    }

    private final func resolveDependencies() {
        var injectables = [AnyInject]()
        
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if child.value is _AnyInject {
                injectables.append(child.value as! AnyInject)
            }
        }

        if injectables.count > 0 {
            let providers = getParents(ofType: DependencyProvider.self)
            for provider in providers {
                for var injectable in injectables {
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
    public final func build() {
        // TODO: check for invalid build
        // TODO: preserve state when it is the second build / n > 0 th build

        #if DEBUG
        if countCalls {
            callCounter.count(.Build)
        }
        
        inspectionBus.publish(WidgetInspectionMessage(sender: self, content: .BuildStarted))
        #endif

        let oldChildren = children

        for oldChild in oldChildren {
            oldChild.destroy()
        }

        performBuild()

        mountChildren(oldChildren: oldChildren)

        buildInvalid = false

        #if DEBUG
        inspectionBus.publish(WidgetInspectionMessage(sender: self, content: .BuildFinished))
        #endif

        invalidateBoxConfig()
        invalidateLayout()
        invalidateRenderState()
    }

    open func performBuild() {
        
    }

    /**
    Checks whether the state of the old children can be transferred to the new children and if yes, applies it.
    */
    private final func mountChildren(oldChildren: [Widget]) {
        var keyedChildren: [String: Widget] = [:]
        var checkChildren: [Widget] = oldChildren

        while let child = checkChildren.popLast() {
            if let key = child.key {
                keyedChildren[key] = child
            }

            checkChildren.append(contentsOf: child.children)
        }

        /* OLD CODE TAKEN OUT OF MOUNT
        // TODO: reimplement state retaining
        for i in 0..<children.count {
            let oldChild: Widget?
            if let oldSelf = oldSelf {
                oldChild = oldSelf.children.count > i ? oldSelf.children[i] : nil
            } else {
                oldChild = nil
            }

            let childContext = oldChild == nil && context == nil ? nil : ReplacementContext(
                previousWidget: oldChild, keyedWidgets: replacementContext?.keyedWidgets ?? [:])
        
            mountChild(children[i], with: childContext)
        }
        */

        for i in 0..<children.count {
            let newChild = children[i]
            let oldChild: Widget? = oldChildren.count > i ? oldChildren[i] : nil
            let childContext = ReplacementContext(previousWidget: oldChild, keyedWidgets: keyedChildren)
            mountChild(newChild, with: childContext)
        }

       /* for child in oldChildren {
            child.destroy()
        }*/
    }

    public func mountChild(_ child: Widget, with replacementContext: ReplacementContext? = nil) {
        child.mount(parent: self, context: context, lifecycleBus: lifecycleBus, with: replacementContext)

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
        
        _ = child.onFocusChanged { [weak self] in
            if let self = self {
                self.focused = $0
            }
        }
    }

    @inlinable
    public final func invalidateBuild() {
        if buildInvalid {
            #if DEBUG
            Logger.warn("Called invalidateBuild() on a Widget where build is already invalid: \(self)", context: .WidgetBuilding)
            #endif
            return
        }

        if !mounted || destroyed {
            #if DEBUG
            Logger.warn("Called invalidateBuild() on a Widget that has not yet been mounted or is already destroyed: \(self)", context: .WidgetBuilding)
            #endif
            return
        }

        _invalidateBuild()
    }

    @usableFromInline
    @inlinable
    internal final func _invalidateBuild() {
        #if DEBUG
        inspectionBus.publish(WidgetInspectionMessage(sender: self, content: .BuildInvalidated))
        #endif

        buildInvalid = true

        lifecycleBus.publish(WidgetLifecycleMessage(sender: self, content: .BuildInvalidated))
        
        #if DEBUG
        context.inspectionBus.publish(WidgetInspectionMessage(sender: self, content: .BuildInvalidated))
        #endif
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

    public final func updateBoxConfig() {
        // TODO: implement inspection messages
        let currentBoxConfig = boxConfig
        let newBoxConfig = getBoxConfig()
        if currentBoxConfig != newBoxConfig {
            _boxConfig = newBoxConfig
            onBoxConfigChanged.invokeHandlers(BoxConfigChangedEvent(old: currentBoxConfig, new: newBoxConfig))
            invalidateLayout()
        }
        boxConfigInvalid = false
    }

    open func getBoxConfig() -> BoxConfig {
        fatalError("getBoxConfig() not implemented for Widget \(self).")
    }

    // TODO: maybe call this updateBoxConfig / or queueBoxConfigUpdate??? --> on next tick?
    @inlinable
    public final func invalidateBoxConfig() {
        if boxConfigInvalid {
            #if DEBUG
            Logger.warn("Called invalidateBoxConfig() on a Widget where box config is already invalid", context: .WidgetLayouting)
            #endif
            return
        }
        boxConfigInvalid = true
        lifecycleBus.publish(WidgetLifecycleMessage(sender: self, content: .BoxConfigInvalidated))
        #if DEBUG
        context.inspectionBus.publish(WidgetInspectionMessage(sender: self, content: .BoxConfigInvalidated))
        #endif
        onBoxConfigInvalidated.invokeHandlers(Void())
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

    @usableFromInline
    internal final func _layout(constraints: BoxConstraints) {
        if constraints.minWidth.isInfinite || constraints.minHeight.isInfinite {
            fatalError("Widget received constraints that contain infinite value in min size: \(self)")
        }

        #if (DEBUG)
        context.inspectionBus.publish(WidgetInspectionMessage(
            sender: self,
            content: .LayoutingStarted))
        
        if countCalls {
            if callCounter.count(.Layout) && burstHighlightEnabled {
                flashHighlight()
                context.inspectionBus.publish(
                    WidgetInspectionMessage(sender: self, content: .LayoutBurstThresholdExceeded))
            }
        }
        Logger.log("Layouting Widget: \(self)".with(fg: .Blue, style: .Bold), level: .Message, context: .WidgetLayouting)
        Logger.log("Constraints: \(constraints)", level: .Message, context: .WidgetLayouting)
        Logger.log("Current size: \(bounds.size)", level: .Message, context: .WidgetLayouting)
        #endif

        layouting = true

        onLayoutingStarted.invokeHandlers(constraints)

        let previousSize = size
        let isFirstRound = !layouted

        #if DEBUG
        let startTimestamp = Date.timeIntervalSinceReferenceDate
        #endif

        let newUnconstrainedSize = performLayout(constraints: constraints)

        #if DEBUG
        let layoutDuration = Date.timeIntervalSinceReferenceDate - startTimestamp
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
        
        #if DEBUG
        context.inspectionBus.publish(WidgetInspectionMessage(
            sender: self,
            content: .LayoutingFinished))
        #endif

        // TODO: where to call this? after setting bounds or before?
        onLayoutingFinished.invokeHandlers(bounds.size)

        if previousSize != size && !isFirstRound {
            Logger.log("Size changed and is not first round.".with(fg: .Yellow), level: .Message, context: .WidgetLayouting)
            onSizeChanged.invokeHandlers(size)
            invalidateRenderState()
        }

        self.previousConstraints = constraints
    }

    open func performLayout(constraints: BoxConstraints) -> DSize2 {
        fatalError("performLayout(constraints:) not implemented.")
    }

    @inlinable
    public final func invalidateLayout() {
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
        context.inspectionBus.publish(
            WidgetInspectionMessage(
                sender: self,
                content: .LayoutInvalidated))
        #endif
        layoutInvalid = true
        onLayoutInvalidated.invokeHandlers(Void())
        lifecycleBus.publish(WidgetLifecycleMessage(sender: self, content: .LayoutInvalidated))
    }

    /// Returns the result of renderContent() wrapped in an IdentifiedSubTreeRenderObject
    @inlinable
    public final func render() -> RenderObject.IdentifiedSubTree {
        if renderState.invalid && mounted && !destroyed {
            #if DEBUG
            if countCalls {
                if callCounter.count(.Render) {
                    context.inspectionBus.publish(WidgetInspectionMessage(
                        sender: self, content: .RenderBurstThresholdExceeded))
                }
            }

            Logger.log("Render state of Widget: \(self) invalid. Rerendering.".with(fg: .Yellow), level: .Message, context: .WidgetRendering)
            #endif

            updateRenderState()
        } else if !mounted || destroyed {
            #if DEBUG
            Logger.log("Widget: \(self) is not mounted or already destroyed. Skip rendering.".with(fg: .Yellow), level: .Message, context: .WidgetRendering)
            #endif
        } else {
            #if DEBUG
            Logger.log("Render state of Widget: \(self) valid. Using cached state.".with(fg: .Yellow), level: .Message, context: .WidgetRendering)
            #endif
        }

        return renderState.content!
    }

    @usableFromInline
    internal final func updateRenderState() {
        if !renderState.invalid {
            #if DEBUG
            Logger.warn("Called updateRenderState on Widget where renderState is not invalid.".with(fg: .White, bg: .Red), context: .WidgetRendering)
            #endif
            return
        } else if !mounted || destroyed {
            #if DEBUG
            Logger.warn("Called updateRenderState on Widget that is not yet mounted or was destroyed.".with(fg: .White, bg: .Red), context: .WidgetRendering)
            #endif
            return
        }

        #if DEBUG
        let startTime = Date.timeIntervalSinceReferenceDate
        context.inspectionBus.publish(WidgetInspectionMessage(
            sender: self, content: .RenderingStarted))
        #endif

        let subTree = renderState.content ?? IdentifiedSubTreeRenderObject(id, [])

        if visibility == .Visible, mounted && layouted && !layouting {
            subTree.removeChildren()

            if let content = renderContent() {
                subTree.appendChild(content)
            }
            
            #if DEBUG
            if debugLayout {
                subTree.appendChild(renderLayoutDebuggingInformation())
            }

            if highlighted {
                subTree.appendChild(
                    RenderStyleRenderObject(fillColor: .Red) {
                        RectangleRenderObject(globalBounds)
                    }
                )
            }
            #endif
        } else {
            #if DEBUG
            Logger.warn("Called updateRenderState on Widget that cannot be rendered in it's current state.".with(fg: .White, bg: .Red), context: .WidgetRendering)
            #endif
        }

        renderState.content = subTree
        renderState.invalid = false

        #if DEBUG
        context.inspectionBus.publish(WidgetInspectionMessage(
            sender: self, content: .RenderingFinished))
        #endif
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
    @inlinable
    public final func invalidateRenderState(deep: Bool = false) {
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

    @inlinable
    public final func invalidateRenderState(deep: Bool = false, after block: () -> ()) {
        block()
        invalidateRenderState(deep: deep)
    }

    @usableFromInline
    internal final func _invalidateRenderState(deep: Bool) {
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
        lifecycleBus.publish(WidgetLifecycleMessage(sender: self, content: .RenderStateInvalidated))
        #if DEBUG
        context.inspectionBus.publish(WidgetInspectionMessage(sender: self, content: .RenderStateInvalidated))
        #endif
    }

    @discardableResult
    open func requestFocus() -> Self {
        if focusable {
            // TODO: maybe run requestfocus and let the context notify the focused widget of receiving focus?
            if mounted {
                //focusContext.requestFocus(self)
                context.requestFocus(self)
            } else {
                _ = onMounted.once { [unowned self] in
                    context.requestFocus(self)
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

    var nextTickHandlerRemovers: [() -> ()] = []

    /**
    Run something on the next tick.
    */
    public func nextTick(_ block: @escaping (Tick) -> ()) {
        let remove = context.onTick.once(block)
        nextTickHandlerRemovers.append(remove)
    }
    
    /**
    Can be used for debugging purposes to highlight a specific Widget, helping to identify it on the screen.
    Only available in debug builds.
    */
    @usableFromInline
    internal func flashHighlight() {
        #if DEBUG
        highlighted = true
        invalidateRenderState()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if let self = self {
                self.nextTick() { _ in
                    self.highlighted = false
                    self.invalidateRenderState()
                }
            }
        }
        #else
        fatalError("flashHighlight() is only available in debug builds")
        #endif
    }

    // TODO: how to name this?
    public final func destroy() {
        for child in children {
            child.destroy()
        }
        
        mounted = false
        
        undoContextSetup()
        
        if var reference = reference {
            if reference.anyReferenced === self {
                reference.anyReferenced = nil
            }
        }

        // TODO: maybe automatically clear all EventHandlerManagers / WidgetEventHandlerManagers by using reflection?
        

        for remove in nextTickHandlerRemovers {
            remove()
        }

        parent = nil

        destroySelf()
        
        onDestroy.invokeHandlers(Void())

        onParentChanged.removeAllHandlers()
        //onAnyParentChanged.removeAllHandlers()
        onMounted.removeAllHandlers()
        onBoxConfigChanged.removeAllHandlers()
        onSizeChanged.removeAllHandlers()
        onLayoutInvalidated.removeAllHandlers()
        onLayoutingStarted.removeAllHandlers()
        onLayoutingFinished.removeAllHandlers()
        onRenderStateInvalidated.removeAllHandlers()
        onDestroy.removeAllHandlers()

        let mirror = Mirror(reflecting: self)
        for child in mirror.allChildren {
            if var manager = child.value as? AnyWidgetEventHandlerManager {
                manager.removeAllHandlers()
                manager.widget = nil
            } else if var manager = child.value as? AnyEventHandlerManager {
                manager.removeAllHandlers()
            }
        } 

        destroyed = true

        Logger.log("Destroyed Widget: \(self), \(id)", level: .Message, context: .Default)
    }

    open func destroySelf() {}
}

extension Widget {
    public enum Visibility {
        case Visible, Hidden
    }

    public struct BoxConfigChangedEvent {
        public var old: BoxConfig
        public var new: BoxConfig
        public init(old: BoxConfig, new: BoxConfig) {
            self.old = old
            self.new = new
        }
    }
}
