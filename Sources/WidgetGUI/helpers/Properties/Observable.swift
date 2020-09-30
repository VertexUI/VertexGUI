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

    public var projectedValue: Observable {

        get {
            
            return self
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

// TODO: implement ObservableArray of Observables --> emit changed event if one item changes
@propertyWrapper
public class ObservableArray<Value>: Observable<[Value]>, Collection {

    public typealias Index = Int

    public typealias Element = Value

    public typealias Iterator = IndexingIterator<[Value]>

    //private var value: [Value]

    //public internal(set) var onChanged = EventHandlerManager<[Value]>()

    override public var wrappedValue: [Value] {

        get {

            value
        }

        set {

            value = newValue
        }
    }

    override public var projectedValue: ObservableArray<Value> {

        get {
            
            return self
        }
    }

    override public init(_ initialValue: [Value] = []) {

        super.init(initialValue)
    }

    private func invokeOnChangedHandlers() {

        onChanged.invokeHandlers(value)
    }

    public var startIndex: Index {

        value.startIndex
    }

    public var endIndex: Index {

        value.endIndex
    }

    public func makeIterator() -> Iterator {

        value.makeIterator()
    }

    public subscript(position: Index) -> Element {

        get {

            value[position]
        }

        set {
            
            value[position] = newValue

            invokeOnChangedHandlers()
        }
    }

    public var isEmpty: Bool {

        value.isEmpty
    }

    public var count: Int {

        value.count
    }

    public func index(after i: Index) -> Index {

        value.index(after: i)
    }

    public func append(_ newValue: Value) {

        value.append(newValue)

        invokeOnChangedHandlers()
    }

    public func append<S>(contentsOf newValues: S) where S: Sequence, Value == S.Element {

        value.append(contentsOf: newValues)

        invokeOnChangedHandlers()
    }

    public func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {

        try value.removeAll(where: shouldBeRemoved)

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

    deinit {

        if let remove = removeOnChangedHandler {

            remove()
        }
    }
}