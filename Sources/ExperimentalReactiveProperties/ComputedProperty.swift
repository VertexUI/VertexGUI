import Events

public class ComputedProperty<Value>: ReactiveProperty, EventfulObject {
  public typealias Value = Value
  public typealias ComputeFunction = () -> Value

  private let compute: ComputeFunction
  private let dependencies: [AnyReactiveProperty]
  private var dependencyHandlerRemovers = [() -> ()]()
  
  private var _value: Value? {
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
    if !hasValue || !valueCalculated {
      _value = compute()
      hasValue = true
      valueCalculated = true
    }
    if _value == nil {
      return _value as! Value
    } else {
      return _value!
    }
  }
  public let onChanged = EventHandlerManager<(old: Value, new: Value)>()
  public let onAnyChanged = EventHandlerManager<(old: Any, new: Any)>()

  public private(set) var hasValue: Bool = false {
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

  private var destroyed: Bool = false
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
  }

  /**
  Initialize with manual dependency definition. No further lookup or is performed
  on dependencies of the compute function.
  */
  public init(compute: @escaping ComputeFunction, dependencies: [AnyReactiveProperty]) {
    self.compute = compute
    self.dependencies = dependencies
    setupDependencyHandlers()
  }

  private func setupDependencyHandlers() {
    for dependency in dependencies {
      dependencyHandlerRemovers.append(dependency.onAnyChanged { [unowned self] _ in
        updateValue()
      })
      dependencyHandlerRemovers.append(dependency.onHasValueChanged { [unowned self] _ in
        checkUpdateHasValue()
      })
    }
  }

  private func removeDependencyHandlers() {
    for remove in dependencyHandlerRemovers {
      remove()
    }
    dependencyHandlerRemovers = []
  }

  private func updateValue() {
    if hasValue {
      _value = compute()
    }
  }

  private func checkUpdateHasValue() {
    hasValue = dependencies.allSatisfy { $0.hasValue }
  }

  public func destroy() {
    if destroyed {
      return
    }
    removeDependencyHandlers()
    registeredBindings = []
    destroyed = true
    onDestroyed.invokeHandlers(())
    removeAllEventHandlers()
  }

  deinit {
    destroy()
  }
}