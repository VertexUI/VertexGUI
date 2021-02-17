import Events

@propertyWrapper
public class MutableComputedProperty<Value>: InternalMutablePropertyProtocol, ComputedPropertyProtocol, EventfulObject {
  public typealias Value = Value

  private var applyingValue = false
  internal var _value: Value? {
    didSet {
      if applyingValue {
        return
      }

      if oldValue != nil {
        invokeOnChangedHandlers(oldValue: oldValue!, newValue: _value!)
      } else {
        hasValue = true
      }
    }
  }
  public var value: Value {
    get {
      handleDependencyRecording()

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
  internal var dependencies: [AnyReactiveProperty]
  internal var dependencyHandlerRemovers = [() -> ()]()
  internal var compute: () -> Value
  internal var apply: (Value) -> ()
  public let onChanged = EventHandlerManager<(old: Value, new: Value)>()
  public let onAnyChanged = EventHandlerManager<(old: Any, new: Any)>()

  public var wrappedValue: Value {
    get {
      value
    }
    set {
      value = newValue
    }
  }

  public var projectedValue: MutableComputedProperty<Value> {
    self
  }

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

  public init() {
    self.compute = { fatalError("called compute() on a property that has not been fully initialized") }
    self.apply = { _ in fatalError("called apply() on a property that has not been fully initialized") }
    self.dependencies = []
  }

  public init(compute: @escaping () -> Value, apply: @escaping (Value) -> (), dependencies: [AnyReactiveProperty]? = nil) {
    self.compute = compute
    self.apply = apply
    if let dependencies = dependencies {
      self.dependencies = dependencies
    } else {
      self.dependencies = []
      recordDependencies()
    }
    setupDependencyHandlers()
    checkUpdateHasValue()
    if hasValue {
      _value = compute()
    }
  }

  public func reinit(compute: @escaping () -> Value, apply: @escaping (Value) -> (), dependencies: [AnyReactiveProperty]? = nil) {
    removeDependencyHandlers()
    self.compute = compute
    self.apply = apply
    if let dependencies = dependencies {
      self.dependencies = dependencies
    } else {
      self.dependencies = []
      recordDependencies()
    }
    setupDependencyHandlers()
    checkUpdateHasValue()
    if hasValue {
      _value = compute()
    }
  }
}