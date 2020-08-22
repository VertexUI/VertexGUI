import VisualAppBase
import CustomGraphicsMath

// TODO: implement function for checking whether render object has content at certain position (--> is not transparent) --> used for mouse events like click etc.
// TODO: might split into SubTreeRenderObject and LeafRenderObject!!!
open class RenderObject: CustomDebugStringConvertible, TreeNode {
    public typealias IdentifiedSubTree = VisualAppBase.IdentifiedSubTreeRenderObject
    public typealias Container = VisualAppBase.ContainerRenderObject
    public typealias Uncachable = VisualAppBase.UncachableRenderObject
    public typealias CacheSplit = VisualAppBase.CacheSplitRenderObject
    public typealias RenderStyle = VisualAppBase.RenderStyleRenderObject
    public typealias Translation = VisualAppBase.TranslationRenderObject
    public typealias Rectangle = VisualAppBase.RectangleRenderObject
    public typealias LineSegment = VisualAppBase.LineSegmentRenderObject
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
        fill: FillRenderValue?, 
        strokeWidth: Double?, 
        strokeColor: StrokeRenderValue?,
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
}
/*public enum RenderObject {
    case Custom(_ render: (_ renderer: Renderer) throws -> Void)
    indirect case Container(_ children: [Self])
}*/