import Events

public class ComputedProperty<Value>: ComputedPropertyProtocol, EventfulObject {
  public typealias Value = Value
  public typealias ComputeFunction = () -> Value
  
  internal var _value: Value? {
    didSet {
      valueCalculated = true
      if hasValue, oldValue != nil {
        hasValue = true
        invokeOnChangedHandlers(oldValue: oldValue as! Value, newValue: _value as! Value)
      } else {
        hasValue = true
      }
    }
  }
  public var value: Value {
    if hasValue {
      if !valueCalculated {
        _value = compute()
        valueCalculated = true
      }

      return _value!
    } else {
      fatalError("no value present, because some dependency does not have a value")
    }
  }
  internal let compute: ComputeFunction
  internal let dependencies: [AnyReactiveProperty]
  internal var dependencyHandlerRemovers = [() -> ()]()
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
  /** Further indicate that while a value might be theoretically available, it has also been calculated and stored. */
  private var valueCalculated = false

  public var registeredBindings = [PropertyBindingProtocol]()

  public internal(set) var destroyed: Bool = false
  public let onDestroyed = EventHandlerManager<Void>()

  /**
  Dependencies of compute function will be automatically determind. This might not be 
  suitable for all types of compute functions. Use init(compute:, dependencies:) if you
  want to specify the dependencies manually.
  */
  public init(compute: @escaping ComputeFunction) {
    self.compute = compute
    self.dependencies = []
    setupDependencyHandlers()
    checkUpdateHasValue()
  }

  /**
  Initialize with manual dependency definition. No further lookup or is performed
  on dependencies of the compute function.
  */
  public init(compute: @escaping ComputeFunction, dependencies: [AnyReactiveProperty]) {
    self.compute = compute
    self.dependencies = dependencies
    setupDependencyHandlers()
    checkUpdateHasValue()
  }

  deinit {
    destroy()
  }
}