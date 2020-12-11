import Events

@propertyWrapper
public class ComputedProperty<V>: ObservableProperty<V>, ComputedPropertyProtocol {
  public typealias Value = V

  internal var _value: Value?
  override public var value: Value {
    if _value == nil {
      performComputation(force: true, notify: false)
    }
    return _value!
  }

  override public var wrappedValue: Value {
    value
  }

  override public var projectedValue: ObservableProperty<V> {
    self
  }

  public var observable: ObservablePropertyBinding<Value> {
    binding
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
      $0.onAnyChanged { _ in
        performComputation()
      }
    }
  }

  private func removeDependencyHandlers() {
    for remove in dependencyChangedHandlerRemovers {
      remove()
    }
  }

  internal func performComputation(force: Bool = false, notify: Bool = true) {
    if onChanged.handlers.count > 0 || force {
      let previousValue = _value
      _value = compute()

      if notify {
        if let equatableSelf = self as? AnyEquatableObservableProtocol {
          if !equatableSelf.valuesEqual(previousValue, _value) {
            onChanged.invokeHandlers(ObservableChangedEventData(old: previousValue, new: _value as! Value))
          }
        } else {
          onChanged.invokeHandlers(ObservableChangedEventData(old: previousValue, new: _value as! Value))
        }
      }
    } else {
      _value = nil
    }
  }
}

extension ComputedProperty: EquatableObservablePropertyProtocol, AnyEquatableObservableProtocol where V: Equatable {}