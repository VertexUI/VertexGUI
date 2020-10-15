import VisualAppBase

@propertyWrapper
public class ObservableProperty<V>: ObservableProtocol {
  public typealias Value = V

  //private var _value: Value
  public var value: Value {
    fatalError("value not implemented")
    //_value
  }

  public var wrappedValue: Value {
    value
  }

  public var projectedValue: ObservableProperty<Value> {
    return self
  }

  private var _any: AnyObservableProperty?
  public var any: AnyObservableProperty  {
    if _any == nil {
      _any = AnyObservableProperty(self)
    }
    return _any!
  }

  public internal(set) var onChanged = EventHandlerManager<Value>()

  /*private let otherObservable: AnyObject
  private var removeOtherObservableChangedHandler: (() -> ())? = nil*/

  /*public init<O: ObservableProtocol>(from otherObservable: O) where O.Value == Value {
    self.otherObservable = otherObservable
    self._value = otherObservable.value
    self.removeOtherObservableChangedHandler = otherObservable.onChanged { [unowned self] in
      self._value = otherObservable.value
      onChanged.invokeHandlers($0)
    }
  }

  deinit {
    if let remove = removeOtherObservableChangedHandler {
      remove()
    }
    onChanged.removeAllHandlers()
  }*/

  public init() {}
}

// TODO: implement ObservableArray of Observables --> emit changed event if one item changes
/*@propertyWrapper
public class ObservableArrayProperty<Value>: ObservableProperty<[Value]>, Collection {
  public typealias Index = Int
  public typealias Element = Value
  public typealias Iterator = IndexingIterator<[Value]>

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
*/

public class AnyObservableProperty {
  public let onChanged = EventHandlerManager<Void>()
  private unowned let otherObservable: AnyObject
  private var removeOtherObservableChangedHandler: (() -> ())? = nil
 
  public init<V>(_ otherObservable: ObservableProperty<V>) {
    self.otherObservable = otherObservable
    self.removeOtherObservableChangedHandler = otherObservable.onChanged { [unowned self] _ in
      onChanged.invokeHandlers(Void())
    }
  }

  deinit {
    if let remove = removeOtherObservableChangedHandler {
      remove()
    }
    onChanged.removeAllHandlers()
  }
}

