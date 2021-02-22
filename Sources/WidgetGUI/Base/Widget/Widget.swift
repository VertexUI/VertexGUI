import Foundation
import GfxMath
import VisualAppBase
import ColorizeSwift
import ReactiveProperties
import Events

open class Widget: Bounded, Parent, Child, CustomDebugStringConvertible {
    /* identification
    ------------------------------
    */
    public var name: String {
        String(describing: type(of: self))
    }

    public static var nextId: UInt = 2
    public let id: UInt

    // TODO: is this even used?
    open var key: String?

    public var debugDescription: String {
        "\(name) \(id) \(classes) \(treePath)"
    } 
    /* end identification */

    /* tree properties
    ------------------------
    anything that is related to identification, navigation, messaging, etc. in a tree
    */
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

    weak open var parent: Parent? = nil
    public internal(set) var treePath: TreePath = []
    /** The topmost parent or the widget instance itself if not mounted into a parent. */
    public var rootParent: Widget {
        var maxParent = parent as? Widget
        while let nextParent = maxParent?.parent as? Widget {
            maxParent = nextParent
        }
        return maxParent ?? self
    }

    public var children: [Widget] {
        var result = contentChildren
        if scrollingEnabled.x {
            result.append(pseudoScrollBarX)
        }
        if scrollingEnabled.y {
            result.append(pseudoScrollBarY)
        }
        return result
    }
    internal var previousChildren = [Widget]()
    public var contentChildren: [Widget] = [] {
        didSet {
            if mounted && built {
                requestUpdateChildren()
            }
        }
    }

    public var providedDependencies: [Dependency] = []
    /* end tree properties */

    /* lifecycle
    ---------------------------
    */
    public private(set) var lifecycleFlags: [LifecycleFlag] = [.initialized]
    private var lifecycleMethodInvocationSignalBus: Bus<LifecycleMethodInvocationSignal> {
        context.lifecycleMethodInvocationSignalBus
    }
    private var nextLifecycleMethodInvocationIds: [LifecycleMethod: Int] = LifecycleMethod.allCases.reduce(into: [:]) {
        $0[$1] = 0
    }
    /* end lifecycle */
    
    /* layout, position
    -----------------------------------------------------
    */
    @available(*, deprecated, message: "Constraints is now passed as a parameter to layout(constraints:)")
    open var constraints: BoxConstraints? = nil

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
            if oldValue != position {
                invalidateRenderState(deep: true)
            }
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
    
    @inlinable open var bounds: DRect {
        DRect(min: position, size: size)
    }
    
    @inlinable open var globalBounds: DRect {
        cumulatedTransforms.transform(rect: DRect(min: .zero, size: bounds.size))
    }
    
    @inlinable open var globalPosition: DPoint2 {
        cumulatedTransforms.transform(point: .zero)
    }
    
    public internal(set) var cumulatedTransforms: [DTransform2] = []

    public internal(set) var previousConstraints: BoxConstraints?
    /* end layout, position */
 
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

    public internal(set) var mounted = false
    public internal(set) var built = false
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

    /* style
    -----------------
    */   
    open var classes: [String] = [] {
        didSet {
            notifySelectorChanged()
        }
    }
    public internal(set) var pseudoClasses = Set<String>()

    /** storage for the the value from style getter property */
    internal var specificWidgetStyle: Style? = nil 
    /** this style will be added to every widget instance as the last style */ 
    open var style: Style? {
      nil
    }

    /** Style property support declared by the Widget instance's context. */
    public var supportedGlobalStyleProperties: StylePropertySupportDefinitions {
        if let context = _context {
            return context.globalStylePropertySupportDefinitions
        } else {
            return []
        }
    }
    /** 
    // TODO: this property is not used yet, added as a reminder to implement such functionality.

    For which globally defined properties should the lifecycle management of this Widget be done automatically.
    Example: rerendering if a color property changes.
    */
    public var globalPropertyKeysWithAutomaticLifecycleManagement: [StyleKey] {
        []
    }
    /** Style property support declared for this Widget instance as the child of it's parent. 
    Given as a dictionary so that the parent can add properties in groups and conveniently update the groups instead
    of reapplying everything.
    */
    public var supportedParentStyleProperties: [String: StylePropertySupportDefinitions] = [:]
    /** Style property support declared by this Widget instance. */
    open var supportedStyleProperties: StylePropertySupportDefinitions { [] }
    /** */
    public var mergedSupportedStyleProperties: StylePropertySupportDefinitions {
            do {
                return try StylePropertySupportDefinitions(merge: [supportedGlobalStyleProperties] +
                    supportedParentStyleProperties.values + [supportedStyleProperties])
            } catch {
                fatalError("error while merging style property support definitions in Widget: \(self), error: \(error)")
            }
        }

    /** All properties from matched styles and direct properties merged,
    validated and filtered according to the support definitions.  */
    public internal(set) var appliedStyleProperties: [StyleProperty] = []

    /** whether this Widget creates a new scope for the children which it itself instantiates */
    public var createsStyleScope: Bool = false {
        didSet {
            if mounted {
                fatalError("tried to set createsStyleScope at the wrong time, can only set it during init")
            }
        }
    }
    /** the scope this Widget belongs to */
    public var styleScope: UInt = 0
    public static let rootStyleScope: UInt = 1
    internal private(set) static var activeStyleScope: UInt = rootStyleScope

    @discardableResult
    public static func inStyleScope<T>(_ scope: UInt, block: () -> T) -> T {
        let previousActiveStyleScope = Widget.activeStyleScope
        Widget.activeStyleScope = scope
        defer { Widget.activeStyleScope = previousActiveStyleScope }
        return block()
    }

    /** Styles which can be applied to this Widget instance or any of 
    it's children (deep) according to their selector. */
    public var providedStyles: [Style] = []
    var mergedProvidedStyles: [Style] {
        providedStyles + (specificWidgetStyle == nil ? [] : [specificWidgetStyle!])
    }

    internal var matchedStylesInvalid = false
    /** Styles whose selectors match this Widget instance. */
    internal var matchedStyles: [Style] = [] {
        didSet {
            if matchedStyles.count != oldValue.count || !matchedStyles.allSatisfy({ style in oldValue.contains { $0 === style } }) {
                stylePropertiesResolver.styles = matchedStyles
                stylePropertiesResolver.resolve()
            }
        }
    }
    /** Style properties that are applied to this Widget instance directly
    without any selector based testing. */
    public internal(set) var directStyleProperties: [StyleProperties] = [] {
        didSet {
            stylePropertiesResolver.directProperties = directStyleProperties
            stylePropertiesResolver.resolve()
        }
    }

    lazy internal var stylePropertiesResolver = StylePropertiesResolver(
        propertySupportDefinitions: mergedSupportedStyleProperties,
        widget: self)

    // TODO: maybe this belongs into the layout section instead of in the style section?
    // TODO: maybe even create a separate section for universal properties?
    /*@FromStyle(key: AnyDefaultStyleKeys.width)
    public var explicitWidth: Double = 0

    @FromStyle(key: AnyDefaultStyleKeys.height)
    public var explicitHeight: Double = 0*/

    @FromStyle(key: AnyDefaultStyleKeys.padding)
    public var padding: Insets = .zero
    
    @FromStyle(key: AnyDefaultStyleKeys.transform)
    public var styleTransforms: [DTransform2] = []

    @FromStyle(key: AnyDefaultStyleKeys.overflowX)
    public var overflowX: Overflow = .show

    @FromStyle(key: AnyDefaultStyleKeys.overflowY)
    public var overflowY: Overflow = .show

    @FromStyle(key: AnyDefaultStyleKeys.opacity)
    public var opacity: Double = 1

    @FromStyle(key: AnyDefaultStyleKeys.visibility)
    public var visibility: Visibility = .visible

    @FromStyle(key: AnyDefaultStyleKeys.borderWidth)
    public var borderWidth: BorderWidth = .zero

    @FromStyle(key: AnyDefaultStyleKeys.borderColor)
    public var borderColor: Color = .transparent

    @FromStyle(key: AnyDefaultStyleKeys.background)
    public var background: Color = .transparent
    /* end style */

    /* scrolling
    ------------------------------------
    */
    @MutableProperty
    internal var autoScrollingEnabled = (x: false, y: false)
    @ComputedProperty
    internal var scrollingEnabled: (x: Bool, y: Bool)/* {
        didSet {
            updateScrollEventHandlers()
        }
    }*/
    /** removers for event handlers that are registered to manage scrolling */
    private var scrollEventHandlerRemovers: [() -> ()] = []
    private var scrollingSpeed = 20.0
    @MutableProperty
    internal var currentScrollOffset: DVec2 = .zero
    internal var scrollableLength: DVec2 = .zero
    /** Mainly used to avoid scroll bars being translated with the rest of the content. */
    internal var unaffectedByParentScroll = false

    lazy internal var pseudoScrollBarX = ScrollBar(orientation: .horizontal)
    lazy internal var pseudoScrollBarY = ScrollBar(orientation: .vertical)
    /* end scrolling */

    @usableFromInline internal var reference: AnyReferenceProtocol? {
        didSet {
            if var reference = reference {
                reference.anyReferenced = self
            }
        }
    }

    @MutableProperty
    public var debugLayout: Bool = false

    public internal(set) var onParentChanged = EventHandlerManager<Parent?>()
    public let onDependenciesInjected = WidgetEventHandlerManager<Void>()
    public internal(set) var onMounted = EventHandlerManager<Void>()
    public let onBuilt = WidgetEventHandlerManager<Void>()
    public let onBuildInvalidated = WidgetEventHandlerManager<Void>()
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

    /* mouse events
    --------------------------
    */
    public let onClickHandlerManager = EventHandlerManager<GUIMouseButtonClickEvent>()
    public let onMouseDownHandlerManager = EventHandlerManager<GUIMouseButtonDownEvent>()
    public let onMouseUpHandlerManager = EventHandlerManager<GUIMouseButtonUpEvent>()
    public let onMouseMoveHandlerManager = EventHandlerManager<GUIMouseMoveEvent>()
    public let onMouseWheelHandlerManager = EventHandlerManager<GUIMouseWheelEvent>()
    /* end mouse events */
    
    public init() {
        self.id = Self.nextId
        Self.nextId += 1
        self.styleScope = Widget.activeStyleScope
        
        setupWidgetEventHandlerManagers()
        setupFromStyleWrappers()
        setupBoxConfigUpdateTriggers()
        setupScrolling()
    }
    
    /* internal widget setup / management
    -----------------------------------------------------
    */
    private func setupWidgetEventHandlerManagers() {
        let mirror = Mirror(reflecting: self)
        for child in mirror.allChildren {
            if var manager = child.value as? AnyWidgetEventHandlerManager {
                manager.widget = self
            }
        }
    }

    private func setupFromStyleWrappers() {
        let mirror = Mirror(reflecting: self)
        for child in mirror.allChildren {
            if let fromStyle = child.value as? FromStyleProtocol {
                fromStyle.registerWidget(self)
            }
        }
    }

    private func setupBoxConfigUpdateTriggers() {
        _ = stylePropertiesResolver.onResolvedPropertyValuesChanged { [unowned self] data in
            let compareKeys = [
                StyleKeys.width, StyleKeys.height, StyleKeys.minWidth, StyleKeys.minHeight,
                StyleKeys.maxWidth, StyleKeys.maxHeight
            ]
            if compareKeys.contains(where: {
                let old = data.old[$0] as? Double
                let new = data.new[$0] as? Double
                return old != new
            }) {
                invalidateBoxConfig()
            }
        }
    }

    private func setupScrolling() {
        self._scrollingEnabled.reinit(compute: { [unowned self] in
            (
                x: overflowX == .scroll || autoScrollingEnabled.x,
                y: overflowY == .scroll || autoScrollingEnabled.y
            )
        }, dependencies: [$autoScrollingEnabled, $overflowX, $overflowY])
        
        _ = onDestroy(self.$scrollingEnabled.onChanged { [unowned self] _ in
            updateScrollEventHandlers()
        })
    }

    private func updateScrollEventHandlers() {
        for remove in scrollEventHandlerRemovers {
            remove()
        }

        if scrollingEnabled.x || scrollingEnabled.y {
            scrollEventHandlerRemovers.append($currentScrollOffset.onChanged { [unowned self] in
                pseudoScrollBarX.scrollProgress = $0.new.x / width
                pseudoScrollBarY.scrollProgress = $0.new.y / height
                for child in children {
                    context.queueLifecycleMethodInvocation(.resolveCumulatedValues, target: child, sender: self, reason: .undefined)
                }
            })

            scrollEventHandlerRemovers.append(pseudoScrollBarX.$scrollProgress.onChanged { [unowned self] in
                if $0.old != $0.new {
                    currentScrollOffset.x = $0.new * width
                }
            })

            scrollEventHandlerRemovers.append(pseudoScrollBarY.$scrollProgress.onChanged { [unowned self] in
                if $0.old != $0.new { 
                    currentScrollOffset.y = $0.new * height
                }
            })

            scrollEventHandlerRemovers.append(onMouseWheelHandlerManager.addHandler { [unowned self] event in
                processMouseWheelEventUpdateScroll(event)
            })
        }
    }

    /** Used if the widget is in scrolling mode. Updates the scroll position based on mouse wheel events. */
    private func processMouseWheelEventUpdateScroll(_ event: GUIMouseWheelEvent) {
        let enabledDimensions = DVec2(scrollingEnabled.x ? 1 : 0, scrollingEnabled.y ? 1 : 0)
        self.currentScrollOffset -= event.scrollAmount * self.scrollingSpeed * enabledDimensions
        self.currentScrollOffset = max(.zero, min(self.currentScrollOffset, self.scrollableLength))
    }
    /* end internal widget setup / management */

    /** side effect: increments the stored next id for the next call of this function. */
    private func getNextLifecycleMethodInvocationId(_ method: LifecycleMethod) -> Int {
        defer { nextLifecycleMethodInvocationIds[method]! += 1 }
        return nextLifecycleMethodInvocationIds[method]!
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

    final func setupContext() {
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
        print("warn: called undoContextSetup when remove handler is nil")
      }
      if let remove = contextOnTickHandlerRemover {
        remove()
      }
    }

    func setupInhertiableStylePropertiesValues() {
        if let parent = parent as? Widget {
            stylePropertiesResolver.inheritableValues = parent.stylePropertiesResolver.resolvedPropertyValues
            _ = parent.stylePropertiesResolver.onResolvedPropertyValuesChanged { [unowned self] _ in
                stylePropertiesResolver.inheritableValues = parent.stylePropertiesResolver.resolvedPropertyValues
                stylePropertiesResolver.resolve()
            }
        }
    }

    open func performBuild() {
        
    }

    /** Use if children are added after the initial mount, build phase. Executes immediately.
    // TODO: consider whether executing this in root tick handling would be better
    */   
    public final func requestUpdateChildren() {
        context.queueLifecycleMethodInvocation(.updateChildren, target: self, sender: self, reason: .undefined)
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

        onBuildInvalidated.invokeHandlers()
    }

    final func handleChildBoxConfigChanged(child: Widget) {
        Logger.log("Box config of child: \(child) of parent \(self) changed.".with(fg: .blue, style: .bold), level: .Message, context: .WidgetLayouting)

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
                Logger.log("Own box config is changed. Perform layout with previous constraints: \(String(describing: previousConstraints))".with(fg: .yellow), level: .Message, context: .WidgetLayouting)
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

    final public func getBoxConfig() -> BoxConfig {
        if !built {
            return BoxConfig(preferredSize: .zero)
        }

        var boxConfig = getContentBoxConfig()
        let paddingSize = padding.aggregateSize
        boxConfig += paddingSize
        let borderSize = borderWidth.aggregateSize
        boxConfig += borderSize

        if overflowX == .scroll {
            boxConfig.minSize.width = 0
        }
        if overflowY == .scroll {
            boxConfig.minSize.height = 0
        }

        if let explicitMinWidth = stylePropertyValue(StyleKeys.minWidth, as: Double.self) {
            boxConfig.minSize.width = explicitMinWidth
            boxConfig.preferredSize.width = max(boxConfig.minSize.width, boxConfig.preferredSize.width)
            boxConfig.maxSize.width = max(boxConfig.minSize.width, boxConfig.maxSize.width)
        }
        if let explicitMinHeight = stylePropertyValue(StyleKeys.minHeight, as: Double.self) {
            boxConfig.minSize.height = explicitMinHeight
            boxConfig.preferredSize.height = max(boxConfig.minSize.height, boxConfig.preferredSize.height)
            boxConfig.maxSize.height = max(boxConfig.minSize.height, boxConfig.maxSize.height)
        }

        if let explicitMaxWidth = stylePropertyValue(StyleKeys.maxWidth, as: Double.self) {
            boxConfig.maxSize.width = explicitMaxWidth 
            boxConfig.preferredSize.width = min(boxConfig.maxSize.width, boxConfig.preferredSize.width)
            boxConfig.minSize.width = min(boxConfig.minSize.width, boxConfig.maxSize.width)
        }
        if let explicitMaxHeight = stylePropertyValue(StyleKeys.maxHeight, as: Double.self) {
            boxConfig.maxSize.height = explicitMaxHeight 
            boxConfig.preferredSize.height = min(boxConfig.maxSize.height, boxConfig.preferredSize.height)
            boxConfig.minSize.height = min(boxConfig.minSize.height, boxConfig.maxSize.height)
        }

        if let explicitWidth = stylePropertyValue(StyleKeys.width, as: Double.self) {
            boxConfig.minSize.width = explicitWidth
            boxConfig.maxSize.width = explicitWidth
            boxConfig.preferredSize.width = explicitWidth
        }
        if let explicitHeight = stylePropertyValue(StyleKeys.height, as: Double.self) {
            boxConfig.minSize.height = explicitHeight
            boxConfig.maxSize.height = explicitHeight
            boxConfig.preferredSize.height = explicitHeight
        }

        return boxConfig
    }

    /**
    * Needs to be implemented by subclasses.
    * - Returns: the box config of the content of the Widget, which might be a drawing or other Widgets.
    */
    open func getContentBoxConfig() -> BoxConfig {
        fatalError("getContentBoxConfig() not implemented")
    }

    // TODO: maybe call this updateBoxConfig / or queueBoxConfigUpdate??? --> on next tick?
    @inlinable
    public final func invalidateBoxConfig() {
        if !mounted {
            #if DEBUG
            Logger.warn("Called invalidateBoxConfig() before Widget was mounted.")
            #endif
            return
        }
        if boxConfigInvalid {
            #if DEBUG
            Logger.warn("Called invalidateBoxConfig() on a Widget where box config is already invalid", context: .WidgetLayouting)
            #endif
            return
        }
        boxConfigInvalid = true
        context.queueLifecycleMethodInvocation(.updateBoxConfig, target: self, sender: self, reason: .undefined)
        //lifecycleBus.publish(WidgetLifecycleMessage(sender: self, content: .BoxConfigInvalidated))
        onBoxConfigInvalidated.invokeHandlers(Void())
    }

    public final func layout(constraints: BoxConstraints) {
        let invocationId = getNextLifecycleMethodInvocationId(.layout)
        if mounted {
            lifecycleMethodInvocationSignalBus.publish(.started(method: .layout, reason: .undefined, invocationId: invocationId, timestamp: context.applicationTime ))
        }

        if !layoutInvalid, let previousConstraints = previousConstraints, constraints == previousConstraints {
            #if DEBUG
            Logger.log("Constraints equal pervious constraints and layout is not invalid.", "Not performing layout.".with(fg: .yellow), level: .Message, context: .WidgetLayouting)
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

        layouting = true

        onLayoutingStarted.invokeHandlers(constraints)

        for child in children {
            child.position = .zero
        }

        let previousSize = size
        let isFirstRound = !layouted
        
        let boxConfigConstraints = BoxConstraints(minSize: boxConfig.minSize, maxSize: boxConfig.maxSize)
        let constrainedParentConstraints = BoxConstraints(
            minSize: boxConfigConstraints.constrain(constraints.minSize),
            maxSize: boxConfigConstraints.constrain(constraints.maxSize)
        )
        var contentConstraints: BoxConstraints = constrainedParentConstraints - padding.aggregateSize - borderWidth.aggregateSize
        if overflowX == .scroll {
            contentConstraints.maxSize.x = .infinity
        }
        if overflowY == .scroll {
            contentConstraints.maxSize.y = .infinity
        }
        
        let newUnconstrainedContentSize = performLayout(constraints: contentConstraints)

        let targetSize = newUnconstrainedContentSize + padding.aggregateSize + borderWidth.aggregateSize
        
        // warning: this description is possibly outdated
        // final size constraints are used to determine the size of a scroll container
        // the perform layout outputs the size of the whole content
        // -> the content can have any size, because it can be scrolled,
        // therefore it is ok to just apply the max constraints passed in by the parent
        // to the whole widget -> content whill be scrollable if it overflows
        /*var finalSizeConstraints = boxConfigConstraints
        if overflowX == .scroll {
            finalSizeConstraints.maxSize.width = boxConfigConstraints.constrain(constraints.maxSize).width
        }
        if overflowY == .scroll {
            finalSizeConstraints.maxSize.height = boxConfigConstraints.constrain(constraints.maxSize).height
        }*/
        let finalSizeConstraints = BoxConstraints(
            minSize: boxConfigConstraints.constrain(constraints.minSize),
            maxSize: boxConfigConstraints.constrain(constraints.maxSize)
        )
        size = finalSizeConstraints.constrain(targetSize)
        /*print("LAYOUT", self)
        print("size", size)
        print("target size", targetSize)
        print("constraints", constraints)
        print("content constraints", contentConstraints)
        print("box config constraints", boxConfigConstraints)
        print("final size constraints", finalSizeConstraints)
        print("------------")*/
        
        scrollableLength = DVec2(targetSize - size)

        // TODO: implement logic for overflow == .auto

        var scrollBarsLength = DSize2(width, height)
        if scrollingEnabled.x && scrollingEnabled.y {
            scrollBarsLength -= DSize2(pseudoScrollBarY.boxConfig.preferredSize.x, pseudoScrollBarX.boxConfig.preferredSize.y)
        }

        if scrollingEnabled.x {
            pseudoScrollBarX.maxScrollProgress = scrollableLength.x / width
            pseudoScrollBarX.layout(constraints: BoxConstraints(
                size: DSize2(scrollBarsLength.x, pseudoScrollBarX.boxConfig.preferredSize.y)))

            pseudoScrollBarX.position = DVec2(0, height - pseudoScrollBarX.height)
        }
        if scrollingEnabled.y {
            pseudoScrollBarY.maxScrollProgress = scrollableLength.y / height
            pseudoScrollBarY.layout(constraints: BoxConstraints(
                size: DSize2(pseudoScrollBarY.boxConfig.preferredSize.x, scrollBarsLength.y)))

            pseudoScrollBarY.position = DVec2(width - pseudoScrollBarY.width, 0)
        }

        layouting = false
        layouted = true
        layoutInvalid = false
        
        // TODO: where to call this? after setting bounds or before?
        onLayoutingFinished.invokeHandlers(bounds.size)

        if previousSize != size && !isFirstRound {
            onSizeChanged.invokeHandlers(size)
            invalidateRenderState()
        }

        for child in children {
            context.queueLifecycleMethodInvocation(.resolveCumulatedValues, target: child, sender: self, reason: .undefined)
        }

        self.previousConstraints = constraints
    }

    /** Layout the content of a widget. Should be implemented by subclasses.
    - Returns: The size of the layouted content. The returned size may exceed or
    fall short of the given constraints.
    */
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
        layoutInvalid = true
        context.queueLifecycleMethodInvocation(.layout, target: self, sender: self, reason: .undefined)
        onLayoutInvalidated.invokeHandlers(Void())
    }

    @inlinable
    @available(*, deprecated, message: "do not use render object api")
    public final func invalidateRenderState(deep: Bool = false) {

    }

    @inlinable
    @available(*, deprecated, message: "do not use render object api")
    public final func invalidateRenderState(deep: Bool = false, after block: () -> ()) {
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

    deinit {
      if !destroyed {
        fatalError("Deinitialized Widget without calling destroy() first")
      }
      Logger.log("Deinitialized Widget: \(id) \(self)", level: .Message, context: .Default)
    }
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
