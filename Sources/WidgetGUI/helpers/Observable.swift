import VisualAppBase

// TODO: maybe have Observable as base protocol with onChanged and then implement things like ObservableValue, ObservableArray on top of that
@propertyWrapper
public class Observable<Value> {
    private var _value: Value

    public var value: Value {
        get {
            return _value
        }

        set {
            _value = newValue
            // TODO: maybe implement check whether value really has changed (for comparable things)
            onChanged.invokeHandlers(_value)
        }
    }

    public var wrappedValue: Value {
        get {
            return value
        }

        set {
            value = newValue
        }
    }

    public internal(set) var onChanged = EventHandlerManager<Value>()
    
    public init(_ initialValue: Value) {
        _value = initialValue
    }

    public init(wrappedValue: Value) {
        _value = wrappedValue
    }
}

public class ObservableArray<Value>: Collection {
    public typealias Index = Int
    public typealias Element = Value
    public typealias Iterator = IndexingIterator<[Value]>

    private var values: [Value]

    public internal(set) var onChanged = EventHandlerManager<[Value]>()

    public init(_ initialValues: [Value] = []) {
        self.values = initialValues
    }

    private func invokeOnChangedHandlers() {
        onChanged.invokeHandlers(values)
    }

    public var startIndex: Index {
        values.startIndex
    }

    public var endIndex: Index {
        values.endIndex
    }

    public func makeIterator() -> Iterator {
        values.makeIterator()
    }

    public subscript(position: Index) -> Element {
        get {
            values[position]
        }

        set {
            values[position] = newValue
            invokeOnChangedHandlers()
        }
    }

    public var isEmpty: Bool {
        values.isEmpty
    }

    public var count: Int {
        values.count
    }

    public func index(after i: Index) -> Index {
        values.index(after: i)
    }

    public func append(_ newValue: Value) {
        values.append(newValue)
        invokeOnChangedHandlers()
    }

    public func append<S>(contentsOf newValues: S) where S: Sequence, Value == S.Element {
        values.append(contentsOf: newValues)
        invokeOnChangedHandlers()
    }

    public func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
        try values.removeAll(where: shouldBeRemoved)
        invokeOnChangedHandlers()
    }
}

public class AnyObservable {
    public internal(set) var onChanged = EventHandlerManager<Any>()

    private var removeOnChangedHandler: (() -> ())?
    
    public init<Value>(_ observable: Observable<Value>) {
        removeOnChangedHandler = observable.onChanged { [unowned self] value in
            onChanged.invokeHandlers(value)
        }
    }

    public init<Value>(_ observable: ObservableArray<Value>) {
        removeOnChangedHandler = observable.onChanged { [unowned self] value in
            onChanged.invokeHandlers(value)
        }
    }

    deinit {
        if let remove = removeOnChangedHandler {
            remove()
        }
    }
}

/*
@propertyWrapper
public struct Observe<Value> {
    var wrappedValue: Observable<Value>
    
    public init(wrappedValue: Observable<Value>) {
        self.wrappedValue = wrappedValue
    }
}*/