import Events

@propertyWrapper
public class MutableProperty<Value>: MutablePropertyProtocol {
  public typealias Value = Value

  private var _value: Value? {
    didSet {
      if let oldValue = oldValue as? Value {
        hasValue = true
        invokeOnChangedHandlers(oldValue: oldValue, newValue: value)
      } else {
        hasValue = true
        for binding in sourceBindings {
          binding.update()
        }
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

  public var sourceBindings: [PropertyBindingProtocol] = []
  private var sinkBindings: [PropertyBindingProtocol] = []

  public init() {
    hasValue = false
  }

  public init(_ initialValue: Value) {
    self.hasValue = true
    self.value = initialValue
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
  public func bind<Source: ReactiveProperty>(_ other: Source) where Source.Value == Value {
    // maybe let the binding call registerAsSource, registerAsSink on the two
    // properties instead of handling the adding of the binding here?
    // TODO: don't store binding information in the properties, use handlers
    // on the properties like onDestroy which are registered by the binding class
    let binding = UniDirectionalPropertyBinding(source: other, sink: self)
    _ = binding.onDestroyed { [unowned self] in
      sinkBindings.removeAll { $0 === binding }
    }
    sinkBindings.append(binding)
    other.sourceBindings.append(binding)
    if other.hasValue {
      binding.update()
    }
  }

  public func destroy() {
    for binding in sourceBindings + sinkBindings {
      binding.destroy()
    }
  }

  deinit {
    destroy()
  }
}