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

  private weak var _any: AnyObservableProperty?
  public var any: AnyObservableProperty  {
    let returnedAny: AnyObservableProperty
    if let storedAny = _any {
      returnedAny = storedAny
    } else {
      returnedAny = AnyObservableProperty(self)
    }
    //_any = returnedAny
    return returnedAny
  }

  public internal(set) var onChanged = EventHandlerManager<Value>()

  public init() {}

  deinit {
    onChanged.removeAllHandlers()
  }

  public func compute<ComputedValue>(_ computeFunction: @escaping (_ parent: Value) -> ComputedValue) -> ComputedProperty<ComputedValue> {
    ComputedProperty<ComputedValue>([any], compute: {
      // possible retain cycle?
      computeFunction(self.value)
    })
  }
}

internal protocol EquatableObservablePropertyProtocol: AnyEquatableObservablePropertyProtocol {
  associatedtype Value: Equatable
}

extension EquatableObservablePropertyProtocol {
  func valuesEqual(_ value1: Any?, _ value2: Any?) -> Bool {
    if value1 == nil && value2 == nil {
      return true
    } else if let value1 = value1 as? Value, let value2 = value2 as? Value {
      return value1 == value2
    } else {
      return false
    }
  }
}

internal protocol AnyEquatableObservablePropertyProtocol {
  func valuesEqual(_ value1: Any?, _ value2: Any?) -> Bool
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

