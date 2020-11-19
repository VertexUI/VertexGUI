import VisualAppBase

@propertyWrapper
public class MutableProperty<V>: ObservableProtocol, MutableProtocol {
  public typealias Value = V

  private var _value: Value? = nil
  public var value: Value {
    get {
      if let value = _value {
        return value
      } else {
        // assuming that Value itself is an optional
        return _value as! Value
      }
    }
    set {
      let oldValue: Value? = _value
      _value = newValue

      let invokeHandlers: Bool
      if let self = self as? AnyEquatableObservablePropertyProtocol {
        invokeHandlers = !self.valuesEqual(oldValue, _value)
      } else {
        invokeHandlers = true
      }
      
      if invokeHandlers {
        if let value = _value {
          onChanged.invokeHandlers(value)
        } else {
          // assuming that Value itself is an optional
          onChanged.invokeHandlers(_value as! Value)
        }
      }
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

  public var projectedValue: MutableProperty<Value> {
    self
  }

  public var observable: ObservablePropertyBinding<Value> {
    ObservablePropertyBinding(parent: self)
  }

  public var any: AnyObservableProperty {
    observable.any
  }

  public var binding: MutablePropertyBinding<Value> {
    MutablePropertyBinding(parent: self)
  }

  public internal(set) var onChanged = EventHandlerManager<Value>()

  public init(storedValue: Value?) {
    _value = storedValue
  }

  public init(_ initialValue: Value) {
    _value = initialValue
  }

  public init(wrappedValue: Value) {
    _value = wrappedValue
  }
  
  // TODO: maybe put this in ObservableProtocol
  public func compute<ComputedValue>(_ computeFunction: @escaping (_ parent: Value) -> ComputedValue) -> ComputedProperty<ComputedValue> {
    ComputedProperty<ComputedValue>([any], compute: {
      // possible retain cycle?
      computeFunction(self.value)
    })
  }
}

extension MutableProperty: EquatableObservablePropertyProtocol where Value: Equatable {}
extension MutableProperty: AnyEquatableObservablePropertyProtocol where Value: Equatable {}

public class MutablePropertyBinding<V>: MutableProperty<V> {
  override public var value: Value {
    get {
      parent.value
    }
    set {
      parent.value = newValue
    }
  }

  private let parent: MutableProperty<V>

  private var removeParentChangedHandler: (() -> ())? = nil

  public init(parent: MutableProperty<V>) {
    self.parent = parent
    super.init(storedValue: nil)
    self.removeParentChangedHandler = parent.onChanged { [unowned self] in
      self.onChanged.invokeHandlers($0)
    }
  }

  deinit {
    if let remove = removeParentChangedHandler {
      remove()
    }
  }
}
