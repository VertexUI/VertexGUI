import VisualAppBase

@propertyWrapper
public class MutableProperty<V>: ObservableProperty<V>, MutableProtocol {
  //public typealias Value = V

  private var _value: Value?
  override public var value: Value {
    get {
      if let value = _value {
        return value
      } else {
        // assuming that Value itself is an optional
        return _value as! Value
      }
    }
    set {
      _value = newValue
      if let value = _value {
        onChanged.invokeHandlers(value)
      } else {
        // assuming that Value itself is an optional
        onChanged.invokeHandlers(_value as! Value)
      }
    }
  }

  override public var wrappedValue: Value {
    get {
      return value
    }
    set {
      value = newValue
    }
  }

  override public var projectedValue: MutableProperty<Value> {
    self
  }

  public var observe: ObservableProperty<Value> {
    self
  }

  override public init() {
    _value = nil
    super.init()
  }

  public init(_ initialValue: Value) {
    _value = initialValue
  }

  public init(wrappedValue: Value) {
    _value = wrappedValue
  }
}
