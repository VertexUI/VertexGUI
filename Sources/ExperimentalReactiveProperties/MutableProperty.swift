import Events

@propertyWrapper
public class MutableProperty<Value>: MutablePropertyProtocol {
  public typealias Value = Value

  private var _value: Value? {
    didSet {
      if hasValue {
        invokeOnChangedHandlers(oldValue: oldValue as! Value, newValue: _value!)
      } else {
        hasValue = true
      }
    }
  }

  public var value: Value {
    get {
      _value!
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

  private var destroyed: Bool = false
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

  /**
  Add a unidirectional binding to another property. The property bind is called on
  will take the value of the other property when the other property changes. 
  The other property will remain unaffected by any changes to the property bind is called on.
  The value of the other property is immediately assigned to self by this function.
  */
  @discardableResult
  public func bind<Source: ReactiveProperty>(_ other: Source) -> UniDirectionalPropertyBinding where Source.Value == Value, Source.Value: Equatable {
    let binding = UniDirectionalPropertyBinding(source: other, sink: self)
    return binding
  }

  public func destroy() {
    if destroyed {
      return
    }
    registeredBindings = []
    onChanged.removeAllHandlers()
    onAnyChanged.removeAllHandlers()
    onHasValueChanged.removeAllHandlers()
    destroyed = true
    onDestroyed.invokeHandlers(())
    onDestroyed.removeAllHandlers()
  }

  deinit {
    destroy()
  }
}