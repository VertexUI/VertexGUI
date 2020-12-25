import Events

public class ComputedProperty<Value>: ReactiveProperty {
  public typealias Value = Value
  public typealias ComputeFunction = () -> Value

  private let compute: ComputeFunction
  private let dependencies: [AnyReactiveProperty]
  private var dependencyHandlerRemovers = [() -> ()]()
  
  private var _value: Value? {
    didSet {
      if hasValue, oldValue != nil {
        hasValue = true
        invokeOnChangedHandlers(oldValue: oldValue as! Value, newValue: _value as! Value)
      } else {
        hasValue = true
      }
    }
  }
  public var value: Value {
    if !hasValue {
      _value = compute()
      hasValue = true
    }
    return _value as! Value
  }
  public let onChanged = EventHandlerManager<(old: Value, new: Value)>()
  public let onAnyChanged = EventHandlerManager<(old: Any, new: Any)>()

  public private(set) var hasValue: Bool = false {
    didSet {
      onHasValueChanged.invokeHandlers(())
    }
  }
  public let onHasValueChanged = EventHandlerManager<Void>()

  public var sourceBindings: [PropertyBindingProtocol] = []

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
    _value = compute()
  }

  private func checkUpdateHasValue() {
    hasValue = dependencies.allSatisfy { $0.hasValue }
  }

  deinit {
    removeDependencyHandlers()
  }
}