import Events

@propertyWrapper
public class MutableProperty<Value>: MutablePropertyProtocol {
  public typealias Value = Value

  public let onChanged = EventHandlerManager<(old: Value, new: Value)>()
  public let onAnyChanged = EventHandlerManager<(old: Any, new: Any)>()

  private var _value: Value? {
    didSet {
      if let oldValue = oldValue as? Value {
        invokeOnChangedHandlers(oldValue: oldValue, newValue: value)
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

  private var bindings: [PropertyBindingProtocol] = []

  public init() {

  }

  public init(_ initialValue: Value) {
    self.value = initialValue
  }

  public convenience init(wrappedValue: Value) {
    self.init(wrappedValue)
  }

  /**
  Add a unidirectional binding to another property. The property bind is called on
  will take the value of the other property when the other property changes. 
  The other property will remain unaffected by any changes to the property bind is called on.
  */
  public func bind<Source: ReactiveProperty>(_ other: Source) where Source.Value == Value {
    let binding = UniDirectionalPropertyBinding(source: other, sink: self)
    _ = binding.onDestroyed { [unowned self] in
      bindings.removeAll { $0 === binding }
    }
    bindings.append(binding)
  }

  public func destroy() {
    for binding in bindings {
      binding.destroy()
    }
  }

  deinit {
    destroy()
  }
}