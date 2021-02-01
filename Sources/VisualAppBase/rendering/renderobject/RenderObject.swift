import Foundation
import Dispatch
import VisualAppBase
import GfxMath
import Events

// TODO: implement the RenderObjects in a way similar to SVG --> like defining an SVG graphic
// TODO: might split into SubTreeRenderObject and LeafRenderObject!!!
// TODO: rename to drawable
open class RenderObject: CustomDebugStringConvertible, TreeNode {
    // TODO: maybe remove these shorthands
    public typealias IdentifiedSubTree = VisualAppBase.IdentifiedSubTreeRenderObject
    public typealias Container = VisualAppBase.ContainerRenderObject
    public typealias Uncachable = VisualAppBase.UncachableRenderObject
    public typealias CacheSplit = VisualAppBase.CacheSplitRenderObject
    public typealias RenderStyle = VisualAppBase.RenderStyleRenderObject
    public typealias Translation = VisualAppBase.TranslationRenderObject
    public typealias Clip = VisualAppBase.ClipRenderObject
    public typealias Rectangle = VisualAppBase.RectangleRenderObject
    public typealias Ellipse = VisualAppBase.EllipsisRenderObject
    public typealias LineSegment = VisualAppBase.LineSegmentRenderObject
    public typealias Custom = VisualAppBase.CustomRenderObject
    public typealias Text = VisualAppBase.TextRenderObject

    public internal(set) var children: [RenderObject] = []

    open var isBranching: Bool { false }

    weak public internal(set) var parent: RenderObject? = nil

    open var bus = Bus() {
        didSet {
            for child in children {
                child.bus = bus
            }

            if let remove = removeOnTickMessageHandler {
                remove()
            }

            setupOnTick()
        }
    }

    private var _context: RenderObjectContext?
    open var context: RenderObjectContext {
        get {
            _context!
        }
        set {
            _context = newValue
            for child in children {
                child.context = _context!
            }
        }
    }

    open var treePath: TreePath = TreePath([]) {
        didSet {
            for (index, child) in children.enumerated() {
                child.treePath = treePath/index
            }
        }
    }

    open var hasTimedRenderValue: Bool {
        fatalError("hasTimedRenderValue not implemented.")
    }

    /// The hash for the objects properties. Excludes children.
    open var individualHash: Int {
        fatalError("individualHash not implemented.")
    }

    open var debugDescription: String {
        fatalError("debugDescription not implemented.")
    }
    
    public var renderState: RenderObjectRenderState? = nil
    public internal(set) var destroyed = false

    private var nextTickHandlers: [() -> ()] = []
    private var removeNextTickListener: (() -> ())?
    private var removeOnTickMessageHandler: (() -> ())?
    internal let onTick = EventHandlerManager<Tick>()

    internal var mounted = false
    internal let onMounted = EventHandlerManager<Void>()

    public init() {
        setupOnTick()
    }

    public func mount(parent: RenderObject, treePath: TreePath, bus: Bus, context: RenderObjectContext?) {
        self.parent = parent
        self.treePath = treePath
        self.bus = bus
        if let context = context {
            self.context = context
        }
        
        mountChildren()

        self.mounted = true

        onMounted.invokeHandlers(Void())
    }

    internal func mountChildren() {
        for (index, child) in children.enumerated() {
          // TODO: warning: this check is probably insufficient, add more logic to ensure that context, tree path of the child are up to date
            if child.parent !== self {
                child.mount(parent: self, treePath: treePath/index, bus: self.bus, context: self._context)
            }
        }
    }

    public func appendChild(_ child: RenderObject) {
        children.append(child)
        if self.mounted {
            child.mount(parent: self, treePath: treePath/children.count, bus: bus, context: _context)
        }
        //child.parent = self
        //child.bus = bus
        /*if let context = _context {
            child.context = context
        }
        child.treePath = treePath/children.count*/
        bus.up(
            UpwardMessage(sender: self, content: .childrenUpdated)
        )
    }

    public func removeChildren() {
        for child in children {
            child.destroy()
        }
        children = []

        bus.up(
            UpwardMessage(sender: self, content: .childrenUpdated)
        )
    }

    public func replaceChildren(_ newChildren: [RenderObject]) {
        children = newChildren
        mountChildren()
        bus.up(UpwardMessage(sender: self, content: .childrenUpdated))
    }

    internal func nextTick(_ execute: @escaping () -> ()) {
        if removeNextTickListener == nil {
            removeNextTickListener = bus.onDownwardMessage { [weak self] in
                switch $0 {
                case .Tick:
                    for handler in self?.nextTickHandlers ?? [] {
                        handler()
                    }
                    self?.nextTickHandlers = []
                    if let remove = self?.removeNextTickListener {
                        remove()
                    }
                default:
                    break
                }
            }
        }

        self.nextTickHandlers.append(execute)
    }

    private func setupOnTick() {
        removeOnTickMessageHandler = bus.onDownwardMessage { [unowned self] in
            switch $0 {
            case let .Tick(tick):
                onTick.invokeHandlers(tick)
            default:
                break
            }
        }
    }

    /**
    - Returns: Self if object contains point as well as all children (deep) that contain it.
    // TODO: might rename to raycast() --> RaycastResult
    */
    public func objectsAt(point: DPoint2) -> [ObjectAtPointResult] {
        fatalError("objectsAt(point:) not implemented for RenderObject \(self)")
    }

    public struct ObjectAtPointResult {
        public var object: RenderObject
        public var transformedPoint: DPoint2
    }
    
    /**
    Notify the responsible renderer that this object needs to be rerendered
    by passing a message over the bus.
    */
    public func invalidateCache() {
        bus.up(UpwardMessage(sender: self, content: .invalidateCache))
    }

    /*public final func unmount() {
        mounted = false
        parent.removeChild(self)
    }*/

    public final func destroy() {
        for child in children {
            child.destroy()
        }

        if let state = renderState {
            state.destroy()
        }

        let mirror = Mirror(reflecting: self)
        for property in mirror.children {
            if let manager = property.value as? AnyEventHandlerManager {
                manager.removeAllHandlers()
                print("RENDER OBJECT AUTOREMOVE HANDLERS!")
            }
        }        

        destroySelf()
        destroyed = true
    }
    
    open func destroySelf() {
    }

    deinit {
        if !destroyed {
            destroy()
            //fatalError("deinit executed for RenderObject that has not yet been destroyed \(self)")
        }
     
        if let remove = removeOnTickMessageHandler {
            remove()
        }
    }
}

open class SubTreeRenderObject: RenderObject {
    // TODO: maybe instead provide a replaceChildren function that returns a new object
    override final public var isBranching: Bool { true }

    public init(children: [RenderObject]) {

        super.init()
        
        for child in children {

            appendChild(child)
        }
    }

    /// The hash including own properties and the hashes of children.
    var combinedHash: Int {

        var hasher = Hasher()

        hasher.combine(individualHash)

        for child in children {

            if child is SubTreeRenderObject {

                hasher.combine((child as! SubTreeRenderObject).combinedHash)

            } else {

                hasher.combine(child.individualHash)
            }
        }

        return hasher.finalize()
    }

    override public func objectsAt(point: DPoint2) -> [ObjectAtPointResult] {

        var result = [ObjectAtPointResult]()

        for child in children {

            result.append(contentsOf: child.objectsAt(point: point))
        }

        if result.count > 0 {

            result.append(ObjectAtPointResult(object: self, transformedPoint: point))
        }

        return result
    }
}

open class IdentifiedSubTreeRenderObject: SubTreeRenderObject {

    public var id: UInt

    override open var hasTimedRenderValue: Bool {
        return false
    }

    override open var debugDescription: String {
        "IdentifiedSubTreeRenderObject"
    }

    override open var individualHash: Int {
        var hasher = Hasher()
        hasher.combine(id)
        return hasher.finalize()
    }

    public init(_ id: UInt, _ children: [RenderObject]) {
        self.id = id
        super.init(children: children)
    }

    public convenience init(_ id: UInt, @RenderObjectBuilder _ children: () -> [RenderObject]) {
        self.init(id, children())
    }
}

// TODO: is this needed?
open class ContainerRenderObject: SubTreeRenderObject {
    override open var hasTimedRenderValue: Bool {
        return false
    }

    override open var debugDescription: String {
        "ContainerRenderObject"
    }

    override open var individualHash: Int {
        return 0 
    }

    public init(_ children: [RenderObject]) {
        super.init(children: children)
    }

    public convenience init(@RenderObjectBuilder _ children: () -> [RenderObject]) {
        self.init(children())
    }
}

// TODO: maybe add something layer BlendMode
// TODO: is this even needed or should the colors etc. all be added to the individual leaf RenderObjects?
open class RenderStyleRenderObject: SubTreeRenderObject {
    public var fill: AnyRenderValue<Fill>?
    public var strokeWidth: Double?
    public var strokeColor: AnyRenderValue<Color>?

    override open var hasTimedRenderValue: Bool {
        return fill?.isTimed ?? false || strokeColor?.isTimed ?? false
    }

    override open var debugDescription: String {
        "RenderStyleRenderObject"
    }

    private var removeTransitionEndListener: (() -> ())? = nil

    override open var individualHash: Int {
        var hasher = Hasher()
        hasher.combine(fill)
        hasher.combine(strokeWidth)
        hasher.combine(strokeColor)
        return hasher.finalize()
    }

    public init<FillRenderValue: RenderValue, StrokeRenderValue: RenderValue>(
        fill: FillRenderValue? = nil, 
        strokeWidth: Double? = nil, 
        strokeColor: StrokeRenderValue? = nil,
        @RenderObjectBuilder children: () -> [RenderObject]) where 
            FillRenderValue.Value == Fill, StrokeRenderValue.Value == Color  {
                if let fill = fill {
                    self.fill = AnyRenderValue<Fill>(fill) 
                }

                self.strokeWidth = strokeWidth

                if let strokeColor = strokeColor {
                    self.strokeColor = AnyRenderValue<Color>(strokeColor) 
                }

                super.init(children: children())

                if let fill = self.fill {
                    if let timedValue = fill.timedBase {
                        var removeOnTickHandler: (() -> ())? = nil
                        removeOnTickHandler = onTick { [unowned self] tick in
                            if timedValue.startTimestamp <= tick.totalTime {
                                bus.up(UpwardMessage(
                                    sender: self, content: .transitionStarted))

                                if let remove = removeTransitionEndListener {
                                    bus.up(UpwardMessage(
                                        sender: self, content: .transitionEnded
                                    ))

                                    removeTransitionEndListener = nil
                                    remove()
                                }

                                removeOnTickHandler!()

                                removeTransitionEndListener = onTick { [weak self] tick in
                                    if timedValue.endTimestamp <= tick.totalTime {
                                        self?.nextTick {
                                            self?.bus.up(UpwardMessage(
                                                sender: self!, content: .transitionEnded))
                                        }

                                        if let remove = self?.removeTransitionEndListener {
                                            remove()
                                            self?.removeTransitionEndListener = nil
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
    }

    deinit {

    }

    public convenience init<FillRenderValue: RenderValue>(

        fill: FillRenderValue,

        @RenderObjectBuilder children: () -> [RenderObject]) where FillRenderValue.Value == Fill {

            self.init(

                fill: fill,

                strokeWidth: nil,
                
                strokeColor: Optional<FixedRenderValue<Color>>.none,

                children: children)
    }

    public convenience init<StrokeRenderValue: RenderValue>(

        strokeWidth: Double?, 

        strokeColor: StrokeRenderValue?, 

        @RenderObjectBuilder children: () -> [RenderObject]) where StrokeRenderValue.Value == Color {

            self.init(

                fill: Optional<FixedRenderValue<Fill>>.none,

                strokeWidth: strokeWidth,

                strokeColor: strokeColor,

                children: children)
    }

    public convenience init<StrokeRenderValue: RenderValue>(

        fillColor: Color, 

        strokeWidth: Double? = nil, 

        strokeColor: StrokeRenderValue? = nil, 

        @RenderObjectBuilder children: () -> [RenderObject]) where StrokeRenderValue.Value == Color {

            self.init(fill: FixedRenderValue(Fill.Color(fillColor)), strokeWidth: strokeWidth, strokeColor: strokeColor, children: children)     
    }

    public convenience init(

        fillColor: Color,

        @RenderObjectBuilder children: () -> [RenderObject]) {

            self.init(

                fill: FixedRenderValue(Fill.Color(fillColor)),

                strokeWidth: nil,

                strokeColor: Optional<FixedRenderValue<Color>>.none,

                children: children)     
    }
    
    override open func destroySelf() {
        
        if let remove = removeTransitionEndListener {

            remove()
                        
                
            bus.up(UpwardMessage(

                sender: self, content: .transitionEnded))
        }
    }
}

open class TranslationRenderObject: SubTreeRenderObject {
  
    public var translation: DVec2

    override open var hasTimedRenderValue: Bool { false }

    override open var debugDescription: String { "TranslationRenderObject" }

    override open var individualHash: Int {
       
        var hasher = Hasher()
       
        hasher.combine(translation)
      
        return hasher.finalize()
    }

    public init(_ translation: DVec2, children: [RenderObject]) {
      
        self.translation = translation
      
        super.init(children: children)
    }

    public convenience init(_ translation: DVec2, @RenderObjectBuilder children: () -> [RenderObject]) {
        
        self.init(translation, children: children())
    }

    override public func objectsAt(point: DPoint2) -> [ObjectAtPointResult] {

        var result = [ObjectAtPointResult]()

        let reverseTranslatedPoint = point - translation

        for child in children {

            result.append(contentsOf: child.objectsAt(point: reverseTranslatedPoint))
        }

        if result.count > 0 {

            result.append(ObjectAtPointResult(object: self, transformedPoint: point))
        }

        return result
    }
}

open class ClipRenderObject: SubTreeRenderObject {

    public let clipBounds: DRect

    override open var hasTimedRenderValue: Bool { false }

    override open var debugDescription: String { "ClipRenderObject" }

    override open var individualHash: Int {
        
        var hasher = Hasher()

        hasher.combine(clipBounds)

        return hasher.finalize()
    }

    public init(_ clipBounds: DRect, @RenderObjectBuilder children: () -> [RenderObject]) {
        
        self.clipBounds = clipBounds

        super.init(children: children())
    }
}

open class UncachableRenderObject: SubTreeRenderObject {

    override open var hasTimedRenderValue: Bool {
  
        return false
    }

    override open var debugDescription: String {
   
        "UncachableRenderObject"
    }

    override open var individualHash: Int { 0 }

    public init(_ children: [RenderObject]) {

        super.init(children: children)
    }

    public convenience init(@RenderObjectBuilder _ children: () -> [RenderObject]) {

        self.init(children())
    }
}

/// Can be used as a wrapper for e.g. calculation heavy CustomRenderObjects
/// which should get their own cache to avoid triggering heavy calculations if
/// other RenderObjects would need an update in a common cache.
open class CacheSplitRenderObject: SubTreeRenderObject {
    override open var hasTimedRenderValue: Bool {
        return false
    }
    
    override open var debugDescription: String {
        "CacheSplitRenderObject"
    }

    override open var individualHash: Int { 0 }
    
    public init(_ children: [RenderObject]) {
        super.init(children: children)
    }
    public convenience init(@RenderObjectBuilder _ children: () -> [RenderObject]) {
        self.init(children())
    }
}

// TODO: maybe combine Rectangle, Circle, Ellipse into Shape?
// and then provide some static initializers like ShapeRenderObject.Circle etc.?
open class RectangleRenderObject: RenderObject {
    public var rect: DRect
    public var cornerRadii: CornerRadii?

    override open var hasTimedRenderValue: Bool {
        return false
    }
    
    override open var debugDescription: String {
        "RectangleRenderObject"
    }
    
    override open var individualHash: Int {
        var hasher = Hasher()
        hasher.combine(rect)
        return hasher.finalize()
    }
    
    public init(_ rect: DRect, cornerRadii: CornerRadii? = nil) {
        self.rect = rect
        self.cornerRadii = cornerRadii
    }

    override public func objectsAt(point: DPoint2) -> [ObjectAtPointResult] {
        if rect.contains(point: point) {
            return [ObjectAtPointResult(object: self, transformedPoint: point)]
        }
        return []
    }
}

open class ImageRenderObject: RenderObject {
    public var image: Image
    public var bounds: DRect

    override open var hasTimedRenderValue: Bool {
        false
    }

    override open var debugDescription: String {
        "ImageRenderObject"
    }

    override open var individualHash: Int {
        var hasher = Hasher()
        //hasher.combine(image)
        hasher.combine(bounds)
        return hasher.finalize()
    }

    public init(image: Image, bounds: DRect) {
        self.image = image
        self.bounds = bounds
    }

    override public func objectsAt(point: DPoint2) -> [ObjectAtPointResult] {
        if bounds.contains(point: point) {
            return [ObjectAtPointResult(object: self, transformedPoint: point)]
        }
        return []
    }
}

open class VideoRenderObject: RenderObject {
    public var stream: VideoStream
    public var bounds: DRect

    // TODO: might rename hasTimedRenderValue to something like requiresFraemRendering (indicate that it cannot be cached?)
    override open var hasTimedRenderValue: Bool {
        true
    }

    override open var debugDescription: String {
        "VideoRenderObject"
    }

    override open var individualHash: Int {
        var hasher = Hasher()
        hasher.combine(bounds)
        return hasher.finalize()
    }

    public init(stream: VideoStream, bounds: DRect) {
        self.stream = stream
        self.bounds = bounds
        super.init()
        // TODO: or should onMounted be a function like mountSelf (compare: destroySelf)
        _ = onMounted {
            self.bus.up(UpwardMessage(sender: self, content: .addUncachable))
        }
    }

    override public func objectsAt(point: DPoint2) -> [ObjectAtPointResult] {
        if bounds.contains(point: point) {
            return [ObjectAtPointResult(object: self, transformedPoint: point)]
        }
        return []
    }

    override public func destroySelf() {
        UpwardMessage(sender: self, content: .removeUncachable)
    }
}

open class EllipsisRenderObject: RenderObject {
    public var bounds: DRect

    override open var hasTimedRenderValue: Bool {
        return false
    }
    
    override open var debugDescription: String {
        "EllipsisRenderObject"
    }
    
    override open var individualHash: Int {
        var hasher = Hasher()
        hasher.combine(bounds)
        return hasher.finalize()
    }

    public init(_ bounds: DRect) {
        self.bounds = bounds
    }

    override public func objectsAt(point: DPoint2) -> [ObjectAtPointResult] {
        // TODO: check whether point is inside the filled area
        if bounds.contains(point: point) {
            return [ObjectAtPointResult(object: self, transformedPoint: point)]
        }

        return []
    }
}

open class LineSegmentRenderObject: RenderObject {
    public var start: DPoint2
    public var end: DPoint2

    override open var hasTimedRenderValue: Bool {
        return false
    }
    
    override open var debugDescription: String {
        "LineSegmentRenderObject"
    }

    override open var individualHash: Int {
        var hasher = Hasher()
        hasher.combine(start)
        hasher.combine(end)
        return hasher.finalize()
    }

    public init(from start: DPoint2, to end: DPoint2) {
        self.start = start
        self.end = end
    }

    override public func objectsAt(point: DPoint2) -> [ObjectAtPointResult] {
        return []
    }
}

// TODO: maybe Rectangle, Ellipsis, LineSegment RenderObjects should inherit from PathRenderObject
open class PathRenderObject: RenderObject {
    public let path: Path
    
    override open var hasTimedRenderValue: Bool {
        return false
    }
    

    override open var debugDescription: String {
        "PathRenderObject"
    }

    override open var individualHash: Int {
        var hasher = Hasher()
        hasher.combine(path)
        return hasher.finalize()
    }

    public init(_ path: Path) {
        self.path = path
    }

    override public func objectsAt(point: DPoint2) -> [ObjectAtPointResult] {
        // TODO: get path bounds and check simply first
        return []
    }
}

open class CustomRenderObject: RenderObject {
    public var render: (_ renderer: Renderer) -> Void

    override open var hasTimedRenderValue: Bool {
        return false
    } 
    
    override open var debugDescription: String {
        "CustomRenderObject"
    }

    private var id: UInt

    override open var individualHash: Int {
        var hasher = Hasher()
        hasher.combine(id)
        return hasher.finalize()
    }

    /// - Parameter id: Used for hashing, should be unique for each render function.
    public init(id: UInt, _ render: @escaping (_ renderer: Renderer) -> Void) {
        self.id = id
        self.render = render
        super.init()
    }

    override public func objectsAt(point: DPoint2) -> [ObjectAtPointResult] {
        // TODO: implement for CustomRenderObject, maybe add a parameter that handles this
        return []
    }
}

open class TextRenderObject: RenderObject {
    public var text: String
    public var fontConfig: FontConfig
    public var color: Color
    public var topLeft: DVec2
    public var maxWidth: Double?

    override open var hasTimedRenderValue: Bool {
        return false
    }
    
    override open var debugDescription: String {
        "TextRenderObject"
    }
    
    override open var individualHash: Int {
        var hasher = Hasher()
        hasher.combine(text)
        hasher.combine(fontConfig)
        hasher.combine(color)
        hasher.combine(topLeft)
        hasher.combine(maxWidth)
        return hasher.finalize()
    }

    public init(_ text: String, fontConfig: FontConfig, color: Color, topLeft: DVec2, maxWidth: Double? = nil) {
        self.text = text
        self.fontConfig = fontConfig
        self.color = color
        self.topLeft = topLeft
        self.maxWidth = maxWidth
    }

    override public func objectsAt(point: DPoint2) -> [ObjectAtPointResult] {
        let size = context.getTextBoundsSize(text, fontConfig: fontConfig, maxWidth: maxWidth)
        if DRect(min: topLeft, size: size).contains(point: point) {
            return [ObjectAtPointResult(object: self, transformedPoint: point)]
        }
        return []
    }
}
