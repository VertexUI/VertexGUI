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

    private var repetitions: Int

    private var valueAt: (_ progress: Double) -> V

    private var id: UInt

    public func hash(into hasher: inout Hasher) {
        hasher.combine(startTimestamp)
        hasher.combine(duration)
        hasher.combine(endTimestamp)
        hasher.combine(id)
    }

    /// - Parameter id: used for hashing, should be unique to each valueAt function.
    /// - Parameter repetitions: 0 for infinite repetitions, any other value for n repetitions
    public init(id: UInt, startTimestamp: Double, duration: Double, repetitions: Int = 1, valueAt: @escaping (_ progress: Double) -> V) {
        self.startTimestamp = startTimestamp
        self.duration = duration
        self.endTimestamp = startTimestamp + duration * Double(repetitions)
        self.repetitions = repetitions
        self.valueAt = valueAt
        self.id = id
    }

    /// - Parameter timestamp: must be relative
    /// to the same thing startTimestamp is relative to, in seconds
    public func getValue(at timestamp: Double) -> V {
        if duration == 0 || (repetitions > 0 && timestamp > endTimestamp) {
            return valueAt(1)
        }
        return valueAt(min(1, max(0, (timestamp - startTimestamp).truncatingRemainder(dividingBy: duration))))
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