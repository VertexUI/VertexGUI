import Foundation
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

    // TODO: when using the BoxConfig approach might instead have onBoundsInvalidated / BoxConfigInvalidated / LayoutInvalidated
    // to bring the parent to take into account updated pref sizes, max sizes, min sizes etc.
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
    public var layouting = false
    public var layouted = false
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

    private let layoutDebuggingColor = Color.Red

    private let layoutDebuggingTextFontConfig = FontConfig(
        family: defaultFontFamily,
        size: 16,
        weight: .Regular,
        style: .Normal
    )

    open internal(set) var onBoxConfigChanged = EventHandlerManager<BoxConfig>()

    lazy open internal(set) var boxConfig = getBoxConfig()

    // TODO: might need to create something like layoutBounds and renderBounds (area that is invalidated on rerender request --> could be more than layoutBounds and affect outside widgets (e.g. a drop shadow that is not included in layoutBounds))
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

    public init(children: [Widget] = []) {
        self.children = children
    }

    deinit {
        Logger.log(.Message, "Deinitialized Widget: \(id) \(self)")
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
        _ = child.onBoundsChanged { [unowned self] _ in
            // TODO: maybe need special relayout flag / function
            if layouted && !layouting {
                layout()
            }
        }

        _ = child.onBoxConfigChanged { [unowned self] _ in
        
            if layouted && !layouting {

                let oldBoxConfig = boxConfig

                invalidateBoxConfig()

                let newBoxConfig = boxConfig

                if oldBoxConfig == newBoxConfig {

                    layout()
                }
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

            onBoxConfigChanged.invokeHandlers(newBoxConfig)
        }
    }

    // TODO: when using box config and setting bounds before hand can rename this to layoutSelf or layoutContent()
    open func performLayout() {
        fatalError("performLayout() not implemented.")
    }
        
    public final func layout() {
        if !layoutable {
            Logger.log(.Warning, "Called layout() on Widget that is not layoutable: \(self)")
            return
        }

        if layouting {
            Logger.log(.Warning, "Called layout() on Widget while that Widget was still layouting: \(self)")
            return
        }

        layouting = true

        let previousBounds = bounds
        let isFirstRound = !layouted

        performLayout()

        layouted = true
        
        layouting = false

        // if bounds changed and this is not the first layout round
        if self is Expandable {
            Logger.log(.Debug, "BEFORE COMPARE \(previousBounds) \(bounds) \(isFirstRound)")
        }
        if previousBounds != bounds && !isFirstRound {
            if self is Expandable {
                Logger.debug("YES BOUNDS CHANGED AND INVOKE HANDLERS")
            }
            onBoundsChanged.invokeHandlers(bounds)
            invalidateRenderState()
        }
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
            Logger.log(.Warning, "Tried to call invalidateRenderState() on destroyed widget: \(self)")
            return
        }

        if !mounted {
            Logger.log(.Warning, "Called invalidateRenderState() on an unmounted Widget: \(self)")
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
        //print("Destroyed Widget:", id, self)
    }

    open func destroySelf() {}
}

