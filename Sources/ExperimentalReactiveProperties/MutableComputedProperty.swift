import Events

public class MutableComputedProperty<Value>: MutablePropertyProtocol, ComputedPropertyProtocol, EventfulObject {
  public typealias Value = Value

  private var applyingValue = false
  internal var _value: Value? {
    didSet {
      if applyingValue {
        return
      }

      if hasValue, oldValue != nil {
        invokeOnChangedHandlers(oldValue: oldValue!, newValue: _value!)
      } else {
        hasValue = true
      }
    }
  }
  public var value: Value {
    get {
      if hasValue {
        if _value == nil {
          _value = compute()
        }

        return _value!
      } else {
        fatalError("no value present, because some dependency does not have a value")
      }
    }
    set {
      let oldValue = _value

      applyingValue = true
      apply(newValue)
      updateValue()
      applyingValue = false

      hasValue = true
      
      if oldValue != nil {
        invokeOnChangedHandlers(oldValue: oldValue!, newValue: _value!)
      }
    }
  }
  internal let dependencies: [AnyReactiveProperty]
  internal var dependencyHandlerRemovers = [() -> ()]()
  internal let compute: () -> Value
  internal let apply: (Value) -> ()
  public let onChanged = EventHandlerManager<(old: Value, new: Value)>()
  public let onAnyChanged = EventHandlerManager<(old: Any, new: Any)>()

  public internal(set) var hasValue: Bool = false {
    didSet {
      if oldValue != hasValue {
        onHasValueChanged.invokeHandlers(())
      }
    }
  }
  public let onHasValueChanged = EventHandlerManager<Void>()

  public var registeredBindings = [PropertyBindingProtocol]()

  public internal(set) var destroyed: Bool = false
  public let onDestroyed = EventHandlerManager<Void>()

  public init(compute: @escaping () -> Value, apply: @escaping (Value) -> (), dependencies: [AnyReactiveProperty]) {
    self.compute = compute
    self.apply = apply
    self.dependencies = dependencies
    setupDependencyHandlers()
    checkUpdateHasValue()
    if hasValue {
      _value = compute()
    }
  }

  public init(compute: @escaping () -> Value, apply: @escaping (Value) -> ()) {
    self.compute = compute
    self.apply = apply
    self.dependencies = []
    setupDependencyHandlers()
    checkUpdateHasValue()
    if hasValue {
      _value = compute()
    }
  }
}