import CustomGraphicsMath

// TODO: implement function for checking whether render object has content at certain position (--> is not transparent) --> used for mouse events like click etc.
// TODO: might split into SubTreeRenderObject and LeafRenderObject!!!
public protocol RenderObject {
    typealias IdentifiedSubTree = VisualAppBase.IdentifiedSubTreeRenderObject
    typealias Container = VisualAppBase.ContainerRenderObject
    typealias Uncachable = VisualAppBase.UncachableRenderObject
    typealias CacheSplit = VisualAppBase.CacheSplitRenderObject
    typealias RenderStyle = VisualAppBase.RenderStyleRenderObject
    typealias Rect = VisualAppBase.RectRenderObject
    typealias Custom = VisualAppBase.CustomRenderObject
    typealias Text = VisualAppBase.TextRenderObject

    var hasTimedRenderValue: Bool { get }
}

public protocol SubTreeRenderObject: RenderObject {
    var children: [RenderObject] { get set }
}

public protocol RenderValue {
    associatedtype Value
}

public struct FixedRenderValue<V>: RenderValue {
    public typealias Value = V
    public var value: V
    public init(_ value: V) {
        self.value = value
    }
}

public struct TimedRenderValue<V>: RenderValue {
    public typealias Value = V
    /// a timestamp relative to something
    /// (e.g. reference date 1.1.2000, something like that), in seconds
    public var startTimestamp: Double
    /// in seconds
    public var duration: Double

    private var endTimestamp: Double

    private var valueAt: (_ progress: Double) -> V

    public init(startTimestamp: Double, duration: Double, valueAt: @escaping (_ progress: Double) -> V) {
        self.startTimestamp = startTimestamp
        self.duration = duration
        self.endTimestamp = startTimestamp + duration
        self.valueAt = valueAt
    }

    /// - Parameter timestamp: must be relative
    /// to the same thing startTimestamp is relative to, in seconds
    public func getValue(at timestamp: Double) -> V {
        if duration == 0 || timestamp > endTimestamp {
            return valueAt(1)
        }
        return valueAt(min(1, max(0, (timestamp - startTimestamp) / duration)))
    }
}

// TODO: maybe add a ScopedRenderValue as well which retrieves values from a Variables provided by any parent of type VariableDefinitionRenderObject

public struct AnyRenderValue<V>: RenderValue {
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

public struct UncachableRenderObject: SubTreeRenderObject {
    public var children: [RenderObject]

    public var hasTimedRenderValue: Bool {
        return false
    }

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
    
    public init(_ rect: DRect) {
        self.rect = rect
    }
}

public struct CustomRenderObject: RenderObject {
    public var render: (_ renderer: Renderer) throws -> Void

    public var hasTimedRenderValue: Bool {
        return false
    }

    public init(_ render: @escaping (_ renderer: Renderer) throws -> Void) {
        self.render = render
    }
}

public struct TextRenderObject: RenderObject {
    public var text: String
    public var topLeft: DVec2
    public var textConfig: TextConfig
    public var maxWidth: Double?    

    public var hasTimedRenderValue: Bool {
        return false
    }

    public init(_ text: String, topLeft: DVec2, textConfig: TextConfig, maxWidth: Double?) {
        self.text = text
        self.topLeft = topLeft
        self.textConfig = textConfig
        self.maxWidth = maxWidth
    }
}
/*public enum RenderObject {
    case Custom(_ render: (_ renderer: Renderer) throws -> Void)
    indirect case Container(_ children: [Self])
}*/