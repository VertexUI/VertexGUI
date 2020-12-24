import Events

@propertyWrapper
public class MutableProperty<Value>: ReactiveProperty {
  public typealias Value = Value

  public let onChanged = EventHandlerManager<(old: Value, new: Value)>()
  public let onAnyChanged = EventHandlerManager<(old: Any, new: Any)>()

  public var value: Value {
    didSet {
      invokeOnChangedHandlers(oldValue: oldValue, newValue: value)
    }
  }

  public var wrappedValue: Value {
    get {
      value
    }

    set {
      value = newValue
    }
  }

  public init(_ initialValue: Value) {
    self.value = initialValue
  }
}