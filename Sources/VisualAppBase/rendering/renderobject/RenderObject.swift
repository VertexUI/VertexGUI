import VisualAppBase
import CustomGraphicsMath

// TODO: implement the RenderObjects in a way similar to SVG --> like defining an SVG graphic

// TODO: implement function for checking whether render object has content at certain position (--> is not transparent) --> used for mouse events like click etc.
// TODO: might split into SubTreeRenderObject and LeafRenderObject!!!
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
   // public typealias Path = VisualAppBase.PathRenderObject
    public typealias Custom = VisualAppBase.CustomRenderObject
    public typealias Text = VisualAppBase.TextRenderObject

    open var children: [RenderObject] = []
    open var isBranching: Bool { false }

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

    /**
    - Returns: Self if object contains point as well as all children (deep) that contain it.
    */
    public func objectsAt(point: DPoint2) -> [ObjectAtPointResult] {
        fatalError("objectsAt(point:) not implemented for RenderObject \(self)")
    }

    public struct ObjectAtPointResult {

        public var object: RenderObject

        public var transformedPoint: DPoint2
    }
}

open class SubTreeRenderObject: RenderObject {
    // TODO: maybe instead provide a replaceChildren function that returns a new object
    override final public var isBranching: Bool { true }

    public init(children: [RenderObject]) {
        super.init()
        self.children = children
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

    public var render: (_ renderer: Renderer) throws -> Void

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
    public init(id: UInt, _ render: @escaping (_ renderer: Renderer) throws -> Void) {
       
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
   
    public var wrap: Bool
   
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
     
        hasher.combine(wrap)
      
        return hasher.finalize()
    }

    public init(_ text: String, fontConfig: FontConfig, color: Color, topLeft: DVec2, wrap: Bool = false, maxWidth: Double? = nil) {
      
        self.text = text
       
        self.fontConfig = fontConfig
      
        self.color = color
      
        self.topLeft = topLeft
       
        self.wrap = wrap
      
        self.maxWidth = maxWidth
    }

    override public func objectsAt(point: DPoint2) -> [ObjectAtPointResult] {
    
        // TODO: implement this for Text --> need to store bounds / get access via a context

        return []
    }
}