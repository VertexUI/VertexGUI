import VisualAppBase

@propertyWrapper
public class MutableProperty<V>: ObservableProperty<V> {
  //public typealias Value = V

  private var _value: Value
  override public var value: Value {
    get {
      return _value
    }
    set {
      _value = newValue
      onChanged.invokeHandlers(_value)
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

  public init(_ initialValue: Value) {
    _value = initialValue
  }

  public init(wrappedValue: Value) {
    _value = wrappedValue
  }
}