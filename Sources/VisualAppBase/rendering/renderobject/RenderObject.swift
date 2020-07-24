import CustomGraphicsMath

// TODO: implement function for checking whether render object has content at certain position (--> is not transparent) --> used for mouse events like click etc.
// TODO: might split into SubTreeRenderObject and LeafRenderObject!!!
public protocol RenderObject: CustomDebugStringConvertible {
    typealias IdentifiedSubTree = VisualAppBase.IdentifiedSubTreeRenderObject
    typealias Container = VisualAppBase.ContainerRenderObject
    typealias Uncachable = VisualAppBase.UncachableRenderObject
    typealias CacheSplit = VisualAppBase.CacheSplitRenderObject
    typealias RenderStyle = VisualAppBase.RenderStyleRenderObject
    typealias Translation = VisualAppBase.TranslationRenderObject
    typealias Rect = VisualAppBase.RectRenderObject
    typealias Custom = VisualAppBase.CustomRenderObject
    typealias Text = VisualAppBase.TextRenderObject

    var hasTimedRenderValue: Bool { get }

    /// The hash for the objects properties. Excludes children.
    var individualHash: Int { get }
}

public protocol SubTreeRenderObject: RenderObject {
    // TODO: maybe instead provide a replaceChildren function that returns a new object
    var children: [RenderObject] { get set }

    /// The hash including own properties and the hashes of children.
    var combinedHash: Int { get }
}

public extension SubTreeRenderObject {
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

public protocol RenderValue: Hashable {
    associatedtype Value: Hashable
}

public struct FixedRenderValue<V: Hashable>: RenderValue {
    public typealias Value = V
    public var value: V
    public init(_ value: V) {
        self.value = value
    }
}

public struct TimedRenderValue<V: Hashable>: RenderValue {
    public typealias Value = V
    /// a timestamp relative to something
    /// (e.g. reference date 1.1.2000, something like that), in seconds
    public var startTimestamp: Double
    /// in seconds
    public var duration: Double

    private var endTimestamp: Double

    private var valueAt: (_ progress: Double) -> V

    private var id: UInt

    public func hash(into hasher: inout Hasher) {
        hasher.combine(startTimestamp)
        hasher.combine(duration)
        hasher.combine(endTimestamp)
        hasher.combine(id)
    }

    /// - Parameter id: used for hashing, should be unique to each valueAt function.
    public init(startTimestamp: Double, duration: Double, id: UInt, valueAt: @escaping (_ progress: Double) -> V) {
        self.startTimestamp = startTimestamp
        self.duration = duration
        self.endTimestamp = startTimestamp + duration
        self.valueAt = valueAt
        self.id = id
    }

    /// - Parameter timestamp: must be relative
    /// to the same thing startTimestamp is relative to, in seconds
    public func getValue(at timestamp: Double) -> V {
        if duration == 0 || timestamp > endTimestamp {
            return valueAt(1)
        }
        return valueAt(min(1, max(0, (timestamp - startTimestamp) / duration)))
    }


    public static func == (lhs: TimedRenderValue, rhs: TimedRenderValue) -> Bool {
        // TODO: maybe this comparison should be replaced with something more safe
        return lhs.hashValue == rhs.hashValue
    }
}

// TODO: maybe add a ScopedRenderValue as well which retrieves values from a Variables provided by any parent of type VariableDefinitionRenderObject

public struct AnyRenderValue<V: Hashable>: RenderValue {
    public typealias Value = V
    private var fixedBase: FixedRenderValue<V>?
    private var timedBase: TimedRenderValue<V>?    

    public var isTimed: Bool {
        return timedBase != nil
    }

    public init<B: RenderValue>(_ base: B) where B.Value == V {
        switch base {
        case let base as FixedRenderValue<V>:
            self.fixedBase = base
        case let base as TimedRenderValue<V>:
            self.timedBase = base
        default:
            fatalError("Unsupported RenderValue given as base.")
        }
    }

    /// - Returns: Value at timestamp.
    /// If base is fixed, will always return the same, if timed, will return calculated value.
    public func getValue(at timestamp: Double) -> V {
        if fixedBase != nil {
            return fixedBase!.value
        } else {
            return timedBase!.getValue(at: timestamp)
        }
    }
}

public struct IdentifiedSubTreeRenderObject: SubTreeRenderObject {
    public var id: UInt
    public var children: [RenderObject]

    public var hasTimedRenderValue: Bool {
        return false
    }

    public var debugDescription: String {
        "IdentifiedSubTreeRenderObject"
    }

    public var individualHash: Int {
        var hasher = Hasher()
        hasher.combine(id)
        return hasher.finalize()
    }

    public init(_ id: UInt, _ children: [RenderObject]) {
        self.id = id
        self.children = children
    }

    public init(_ id: UInt, @RenderObjectBuilder _ children: () -> [RenderObject]) {
        self.id = id
        self.children = children()
    }
}

// TODO: is this needed?
public struct ContainerRenderObject: SubTreeRenderObject {
    public var children: [RenderObject]

    public var hasTimedRenderValue: Bool {
        return false
    }

    public var debugDescription: String {
        "ContainerRenderObject"
    }

    public var individualHash: Int {
        return 0 
    }

    public init(@RenderObjectBuilder _ children: () -> [RenderObject]) {
        self.children = children()
    }

    public init(_ children: [RenderObject]) {
        self.children = children
    }
}

public struct RenderStyleRenderObject: SubTreeRenderObject {
    public var children: [RenderObject]

    public var fillColor: AnyRenderValue<Color>?
    public var strokeWidth: Double?
    public var strokeColor: AnyRenderValue<Color>?

    public var hasTimedRenderValue: Bool {
        return fillColor?.isTimed ?? false || strokeColor?.isTimed ?? false
    }

    /*public init<C: RenderValue>(fillColor: C? = nil, strokeWidth: Double? = nil, strokeColor: C? = nil, _ children: [RenderObject]) where C.Value == Color {
        //self.renderStyle = renderStyle
        self.children = children
    }*/ 
    public var debugDescription: String {
        "RenderStyleRenderObject"
    }

    public var individualHash: Int {
        var hasher = Hasher()
        hasher.combine(fillColor)
        hasher.combine(strokeWidth)
        hasher.combine(strokeColor)
        return hasher.finalize()
    }

    public init<C: RenderValue>(fillColor: C? = nil, strokeWidth: Double? = nil, strokeColor: C? = nil, @RenderObjectBuilder children: () -> [RenderObject]) where C.Value == Color {
        //self.renderStyle = renderStyle
        self.children = children()
        if let fillColor = fillColor {
            self.fillColor = AnyRenderValue<Color>(fillColor) 
        }
        self.strokeWidth = strokeWidth
        if let strokeColor = strokeColor {
            self.strokeColor = AnyRenderValue<Color>(strokeColor) 
        }
        //self.init(fillColor: fillColor, strokeWidth: strokeWidth, strokeColor: strokeColor, children())
    }
}

public struct TranslationRenderObject: SubTreeRenderObject {
    public var children: [RenderObject]
    public var translation: DVec2

    public var hasTimedRenderValue: Bool = false

    public var debugDescription: String = "TranslationRenderObject"

    public var individualHash: Int {
        var hasher = Hasher()
        hasher.combine(translation)
        return hasher.finalize()
    }

    public init(_ translation: DVec2, children: [RenderObject]) {
        self.translation = translation
        self.children = children
    }

    public init(_ translation: DVec2, @RenderObjectBuilder children: () -> [RenderObject]) {
        self.init(translation, children: children())
    }
}

public struct UncachableRenderObject: SubTreeRenderObject {
    public var children: [RenderObject]

    public var hasTimedRenderValue: Bool {
        return false
    }

    public var debugDescription: String {
        "UncachableRenderObject"
    }

    public var individualHash: Int = 0

    public init(_ children: [RenderObject]) {
        self.children = children
    }
    public init(@RenderObjectBuilder _ children: () -> [RenderObject]) {
        self.children = children()
    }
}

/// Can be used as a wrapper for e.g. calculation heavy CustomRenderObjects
/// which should get their own cache to avoid triggering heavy calculations if
/// other RenderObjects would need an update in a common cache.
public struct CacheSplitRenderObject: SubTreeRenderObject {
    public var children: [RenderObject]
    
    public var hasTimedRenderValue: Bool {
        return false
    }
    
    public var debugDescription: String {
        "CacheSplitRenderObject"
    }

    public var individualHash: Int = 0
    
    public init(_ children: [RenderObject]) {
        self.children = children
    }
    public init(@RenderObjectBuilder _ children: () -> [RenderObject]) {
        self.children = children()
    }
}

public struct RectRenderObject: RenderObject {
    public var rect: DRect

    public var hasTimedRenderValue: Bool {
        return false
    }
    
    public var debugDescription: String {
        "RectRenderObject"
    }
    
    public var individualHash: Int = 0
    
    public init(_ rect: DRect) {
        self.rect = rect
    }
}

public struct CustomRenderObject: RenderObject {
    public var render: (_ renderer: Renderer) throws -> Void

    public var hasTimedRenderValue: Bool {
        return false
    } 
    
    public var debugDescription: String {
        "CustomRenderObject"
    }

    private var id: UInt
    public var individualHash: Int {
        var hasher = Hasher()
        hasher.combine(id)
        return hasher.finalize()
    }

    /// - Parameter id: Used for hashing, should be unique for each render function.
    public init(id: UInt, _ render: @escaping (_ renderer: Renderer) throws -> Void) {
        self.id = id
        self.render = render
    }
}

public struct TextRenderObject: RenderObject {
    public var text: String
    public var topLeft: DVec2
    public var config: TextConfig
    public var maxWidth: Double?

    public var hasTimedRenderValue: Bool {
        return false
    }
    
    public var debugDescription: String {
        "TextRenderObject"
    }
    
    public var individualHash: Int {
        var hasher = Hasher()
        hasher.combine(text)
        hasher.combine(topLeft)
        hasher.combine(config)
        hasher.combine(maxWidth)
        return hasher.finalize()
    }

    public init(_ text: String, config: TextConfig, topLeft: DVec2, maxWidth: Double? = nil) {
        self.text = text
        self.topLeft = topLeft
        self.config = config
        self.maxWidth = maxWidth
    }
}
/*public enum RenderObject {
    case Custom(_ render: (_ renderer: Renderer) throws -> Void)
    indirect case Container(_ children: [Self])
}*/