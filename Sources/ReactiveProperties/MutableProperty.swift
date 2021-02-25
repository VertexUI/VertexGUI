import Events

@propertyWrapper
public class MutableProperty<Value>: InternalMutablePropertyProtocol, EventfulObject {
  public typealias Value = Value

  private var _value: Value? {
    didSet {
      if hasValue {
        invokeOnChangedHandlers(oldValue: oldValue!, newValue: _value!)
      } else {
        hasValue = true
      }
    }
  }

  public var value: Value {
    get {
      handleDependencyRecording()

      if let value = _value {
        return value
      } else {
        fatalError("no value present")
      }
    }
    set {
      _value = newValue
    }
  }
  public let onChanged = EventHandlerManager<(old: Value, new: Value)>()
  public let onAnyChanged = EventHandlerManager<(old: Any, new: Any)>()

  public private(set) var hasValue: Bool {
    didSet {
      if oldValue != hasValue {
        onHasValueChanged.invokeHandlers(())
      }
    }
  }
  public let onHasValueChanged = EventHandlerManager<Void>()

  public var wrappedValue: Value {
    get {
      value
    }
    set {
      value = newValue
    }
  }

  public var projectedValue: MutableProperty<Value> {
    self
  }
 
  public var registeredBindings = [PropertyBindingProtocol]()

  public var destroyed: Bool = false
  public let onDestroyed = EventHandlerManager<Void>()

  public init() {
    hasValue = false
  }

  public init(_ initialValue: Value) {
    self.hasValue = true
    self._value = initialValue
  }

  public convenience init(wrappedValue: Value) {
    self.init(wrappedValue)
  }

  deinit {
    destroy()
  }
}