import VisualAppBase

public class ComputedProperty<V>: ObservableProperty<V> {
  public typealias Value = V

  private var _value: Value?
  override public var value: Value {
    if _value == nil {
      _value = compute()
    }
    return _value!
  }

  private let compute: () -> Value
  private let dependencies: [AnyObservableProperty]
  private var dependencyChangedHandlerRemovers = [() -> ()]()

  public init(_ dependencies: [AnyObservableProperty], compute: @escaping () -> Value) {
    self.compute = compute
    self.dependencies = dependencies
    super.init()
    self.dependencyChangedHandlerRemovers = dependencies.map { [unowned self] in
      $0.onChanged {
        _value = nil
        onChanged.invokeHandlers(value)
      }
    }
  }

  deinit {
    removeDependencyHandlers()
    onChanged.removeAllHandlers()
  }

  private func removeDependencyHandlers() {
    for remove in dependencyChangedHandlerRemovers {
      remove()
    }
  }
}