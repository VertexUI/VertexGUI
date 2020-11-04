import VisualAppBase

@propertyWrapper
public class ComputedProperty<V>: ObservableProperty<V>, ComputedPropertyProtocol {
  public typealias Value = V

  internal var _value: Value?
  override public var value: Value {
    if _value == nil {
      performComputation(force: true)
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
      performComputation()
    }
  }
  public var dependencies: [AnyObservableProperty] {
    didSet {
      removeDependencyHandlers()
      registerDependencyHandlers()
    }
  }
  private var dependencyChangedHandlerRemovers = [() -> ()]()

  // TODO: automatically track dependencies by registering through a static global variable in first call of compute
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
        performComputation()
      }
    }
  }

  private func removeDependencyHandlers() {
    for remove in dependencyChangedHandlerRemovers {
      remove()
    }
  }

  internal func performComputation(force: Bool = false) {
    if onChanged.handlers.count > 0 || force {
      let previousValue = _value
      _value = compute()

      if let equatableSelf = self as? AnyEquatableComputedPropertyProtocol {
        if !equatableSelf.valuesEqual(previousValue, _value) {
          onChanged.invokeHandlers(value)
        }
      } else {
        onChanged.invokeHandlers(value)
      }
    } else {
      _value = nil
    }
  }
}

extension ComputedProperty: EquatableObservablePropertyProtocol, AnyEquatableObservablePropertyProtocol where V: Equatable {}