import Foundation
import WidgetGUI
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

    lazy open internal(set) var boxConfig = getBoxConfig()

    // TODO: might need to create something like layoutBounds and renderBounds (area that is invalidated on rerender request --> could be more than layoutBounds and affect outside widgets (e.g. a drop shadow that is not included in layoutBounds))
    // TODO: make size unsettable from outside when new layout approach completed
    open var bounds: DRect = DRect(min: DPoint2(0,0), size: DSize2(0,0)) {
        didSet {
            if oldValue != bounds {

                if mounted && layouted && !layouting && !destroyed {

                    onBoundsChanged.invokeHandlers(bounds)

                    invalidateRenderState()
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


 
    public internal(set) var focusable = false


    
    public internal(set) var focused = false {
        didSet {
            onFocusChanged.invokeHandlers(focused)
        }
    }

    public private(set) var mounted = false

    // TODO: maybe something better
    public var layoutable: Bool {

        mounted/* && constraints != nil*/ && context != nil
    }

    public private(set) var layouting = false

    public private(set) var layouted = false

    public private(set) var previousConstraints: BoxConstraints?

    // TODO: maybe rename to boundsInvalid???
    public internal(set) var layoutInvalid = true

    public internal(set) var destroyed = false



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

    private let layoutDebuggingTextFontConfig = FontConfig(
        family: defaultFontFamily,
        size: 16,
        weight: .Regular,
        style: .Normal
    )



    public internal(set) var onParentChanged = EventHandlerManager<Parent?>()

    public internal(set) var onAnyParentChanged = EventHandlerManager<Parent?>()

    public internal(set) var onRenderStateInvalidated = EventHandlerManager<Widget>()

    // TODO: when using the BoxConfig approach might instead have onBoundsInvalidated / BoxConfigInvalidated / LayoutInvalidated
    // to bring the parent to take into account updated pref sizes, max sizes, min sizes etc.
    public internal(set) var onBoundsChanged = EventHandlerManager<DRect>()

    open internal(set) var onBoxConfigChanged = EventHandlerManager<BoxConfig>()

    public internal(set) var onFocusChanged = EventHandlerManager<Bool>()

    public internal(set) var onDestroy = EventHandlerManager<Void>()
    
    private var unregisterAnyParentChangedHandler: EventHandlerManager<Parent?>.UnregisterCallback?




    public init(children: [Widget] = []) {
        self.children = children
    }

    deinit {
        Logger.log("Deinitialized Widget: \(id) \(self)", level: .Message, context: .Default)
    }

    public final func with(key: String) -> Self {
        self.key = key
        return self
    }

    public final func with(block: (Self) -> ()) -> Self {
        block(self)
        return self
    }
 
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
    }

    private func resolveDependencies() {
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

        _ = child.onRenderStateInvalidated { [unowned self] in
        
            invalidateRenderState($0)
        }

        // TODO: buffer updates over a certain timespan and then relayout
        _ = child.onBoundsChanged { [unowned self, unowned child] _ in
            // TODO: maybe need special relayout flag / function

            Logger.log("Bounds of child \(child) of parent \(self) changed.".with(fg: .Blue, style: .Bold), level: .Message, context: .WidgetLayouting)

            if layouted && !layouting {

                Logger.log("Performing layout on parent parent.", level: .Message, context: .WidgetLayouting)

                layoutInvalid = true
                
                layout(constraints: previousConstraints!)
            }
        }

        _ = child.onBoxConfigChanged { [unowned self, unowned child] _ in
            
            handleChildBoxConfigChanged(child: child)
        }
    }

    private func handleChildBoxConfigChanged(child: Widget) {

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

                Logger.log("Own box config is changed. Perform layout with previous constraints: \(previousConstraints)".with(fg: .Yellow), level: .Message, context: .WidgetLayouting)

                layoutInvalid = true

                layout(constraints: previousConstraints!)
            }
        }
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

    open func getBoxConfig() -> BoxConfig {
        fatalError("getBoxConfig() not implemented.")
    }

    // TODO: maybe call this updateBoxConfig / or queueBoxConfigUpdate??? --> on next tick?
    public func invalidateBoxConfig() {
        
        let currentBoxConfig = boxConfig

        let newBoxConfig = getBoxConfig()

        if currentBoxConfig != newBoxConfig {

            boxConfig = newBoxConfig

            layoutInvalid = true

            onBoxConfigChanged.invokeHandlers(newBoxConfig)
        }
    }

    open func layout(constraints: BoxConstraints) {

        Logger.log("Attempting layout".with(fg: .Yellow), "on Widget: \(self).", level: .Message, context: .WidgetLayouting)

        if !layoutInvalid, let previousConstraints = previousConstraints, constraints == previousConstraints {/* ||
        
            (constraints.minSize == bounds.size && constraints.maxSize == bounds.size) {*/

            Logger.log("Constraints equal pervious constraints and layout is not invalid.", "Not performing layout.".with(fg: .Yellow), level: .Message, context: .WidgetLayouting)

            return
        }
        
        if !layoutable {
            
            Logger.warn("Called layout() on Widget that is not layoutable: \(self)", context: .WidgetLayouting)

            return
        }

        if layouting {
            
            Logger.warn("Called layout() on Widget while that Widget was still layouting: \(self)", context: .WidgetLayouting)

            return
        }

        Logger.log("Layouting Widget: \(self)".with(fg: .Blue, style: .Bold), level: .Message, context: .WidgetLayouting)
        Logger.log("Constraints: \(constraints)", level: .Message, context: .WidgetLayouting)
        Logger.log("Current size: \(bounds.size)", level: .Message, context: .WidgetLayouting)

        layouting = true

        let previousBounds = bounds

        let isFirstRound = !layouted

        let contentSize = performLayout(constraints: constraints)

        Logger.log("Layout of Widget: \(self) produced result.".with(fg: .Green, style: .Bold), level: .Message, context: .WidgetLayouting)

        Logger.log("Size of content: \(contentSize)", level: .Message, context: .WidgetLayouting)

        Logger.log("New self size: \(constraints.constrain(contentSize))", level: .Message, context: .WidgetLayouting)

        bounds.size = constraints.constrain(contentSize)

        layouting = false

        layouted = true

        layoutInvalid = false

        if previousBounds.size != bounds.size && !isFirstRound {

            Logger.log("Size changed and is not first round.".with(fg: .Yellow), level: .Message, context: .WidgetLayouting)

            onBoundsChanged.invokeHandlers(bounds)

            invalidateRenderState()
        }

        self.previousConstraints = constraints
    }

    // TODO: probably a legacy call --> remove
    @available(*, deprecated, message: "Use layout(constraints:).")
    open func layout() {

        layout(constraints: self.constraints!)

        Logger.warn("Calling legacy layout() function.")
    }

    // TODO: when using box config and setting bounds before hand can rename this to layoutSelf or layoutContent()
    // TODO: this is the legacy version --> remove
    @available(*, deprecated, message: "Use performLayout(constraints:)")
    open func performLayout() {
        
        fatalError("performLayout() not implemented.")
    }
    
    open func performLayout(constraints: BoxConstraints) -> DSize2 {

        Logger.warn("Calling default implementation of performLayout(constraints:) that calls legacy performLayout() on: \(self).")

        performLayout()

        return bounds.size
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

    public final func getParent<T>(ofType type: T.Type) -> T? {
        let parents = getParents(ofType: type)
        return parents.count > 0 ? parents[0] : nil
    }

    /// - Returns: all parents of given type, sorted from nearest to farthest
    public final func getParents<T>(ofType type: T.Type) -> [T] {

        var selectedParents = [T]()

        var currentParent: Parent? = self.parent

        while currentParent != nil {

            if let parent = currentParent as? T {
                selectedParents.append(parent)
            }
            
            if let childParent = currentParent! as? Child {
                currentParent = childParent.parent

            } else {
                break
            }
        }

        return selectedParents
    }

    // TODO: might need possibility to return all of type + a method that only returns first + in what order depth first / breadth first
    public final func getChild<W: Widget>(ofType type: W.Type) -> W? {
        for child in children {

            if let child = child as? W {

                return child
            }
        }
        
        for child in children {

            if let result = child.getChild(ofType: type) {

                return result
            }
        }

        return nil
    }

    public final func getConfig<Config: PartialConfig>(ofType type: Config.Type) -> Config? {
        let configProviders = getParents(ofType: ConfigProvider.self)
        
        let configs = configProviders.compactMap {
            $0.retrieveConfig(ofType: type)
        }

        if configs.count == 0 {
            return nil
        }

        let resultConfig = type.merged(partials: configs)
        
        return resultConfig
    }

    /// Returns the result of renderContent() wrapped in an IdentifiedSubTreeRenderObject
    public final func render() -> IdentifiedSubTreeRenderObject {
        return IdentifiedSubTreeRenderObject(id) {
            if mounted && layouted && !layouting {
                renderContent()

                if debugLayout {
                    renderLayoutDebuggingInformation()
                }
            }
        }
    }

    /// Invoked by render(), if Widget has children, should use child.render() to render them.
    open func renderContent() -> RenderObject? {
        .Container {
            children.map { $0.render() }
        }
    }

    private func renderLayoutDebuggingInformation() -> RenderObject {
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
    public final func invalidateRenderState(_ widget: Widget? = nil) {
        if destroyed {
            Logger.warn("Tried to call invalidateRenderState() on destroyed widget: \(self)", context: .WidgetRendering)
            return
        }

        if !mounted {
            Logger.warn("Called invalidateRenderState() on an unmounted Widget: \(self)", context: .WidgetRendering)
            return
        }

        let widget = widget ?? self

        try! onRenderStateInvalidated.invokeHandlers(widget)
    }

    public final func invalidateRenderState(after block: () -> ()) {
        block()
        invalidateRenderState()
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
        //Logger.log("Destroyed Widget:", id, self, level: .Message, context: .WidgetLayouting)
    }

    open func destroySelf() {}
}

