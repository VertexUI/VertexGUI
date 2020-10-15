import VisualAppBase

@propertyWrapper
public class ComputedProperty<V>: ObservableProperty<V> {
  public typealias Value = V

  private var _value: Value?
  override public var value: Value {
    if _value == nil {
      _value = compute()
    }
    return _value!
  }

  override public var wrappedValue: Value {
    value
  }

  override public var projectedValue: ObservableProperty<V> {
    self
  }

  public var compute: () -> Value {
    didSet {
      _value = nil
      onChanged.invokeHandlers(value)
    }
  }
  public var dependencies: [AnyObservableProperty] {
    didSet {
      removeDependencyHandlers()
      registerDependencyHandlers()
    }
  }
  private var dependencyChangedHandlerRemovers = [() -> ()]()

  public init(_ dependencies: [AnyObservableProperty], compute: @escaping () -> Value) {
    self.compute = compute
    self.dependencies = dependencies
    super.init()
    registerDependencyHandlers()
  }

  override public init() {
    self.compute = { fatalError("no compute function given") }
    self.dependencies = []
  }

  deinit {
    removeDependencyHandlers()
    onChanged.removeAllHandlers()
  }

  private func registerDependencyHandlers() {
    dependencyChangedHandlerRemovers = dependencies.map { [unowned self] in
      $0.onChanged {
        _value = nil
        onChanged.invokeHandlers(value)
      }
    }
  }

  private func removeDependencyHandlers() {
    for remove in dependencyChangedHandlerRemovers {
      remove()
    }
  }
}