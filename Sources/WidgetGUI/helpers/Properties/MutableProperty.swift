import VisualAppBase

@propertyWrapper
public class MutableProperty<V>: ObservableProperty<V>, MutableProtocol {
  //public typealias Value = V

  private var _value: Value? = nil
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

  public var observable: ObservableProperty<Value> {
    self
  }

  public var binding: MutablePropertyBinding<Value> {
    MutablePropertyBinding(parent: self)
  }

  public init(storedValue: Value?) {
    _value = storedValue
  }

  public init(_ initialValue: Value) {
    _value = initialValue
  }

  public init(wrappedValue: Value) {
    _value = wrappedValue
  }
}

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