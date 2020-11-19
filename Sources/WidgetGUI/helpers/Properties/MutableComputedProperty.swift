@propertyWrapper
public class MutableComputedProperty<V>: MutableProperty<V> {
  private var _value: Value?
  override public var value: Value {
    get {
      if _value == nil {
        performComputation(force: true)
      }
      return _value!
    }
    set {
      setValue(newValue)
    }
  }

  override public var wrappedValue: Value {
    get {
      value
    }
    set {
      value = newValue
    }
  }
  public var compute: () -> Value {
    didSet {
      performComputation()
    }
  }
  public var apply: (Value) -> ()
  public var dependencies: [AnyObservableProperty] {
    didSet {
      removeDependencyHandlers()
      registerDependencyHandlers()
    }
  }
  private var dependencyChangedHandlerRemovers = [() -> ()]()

  public init(
    _ dependencies: [AnyObservableProperty],
    compute: @escaping () -> Value,
    apply: @escaping (Value) -> ()) {
      self.apply = apply
      self.compute = compute
      self.dependencies = dependencies
      super.init(storedValue: nil)
      registerDependencyHandlers()
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

      if let equatableSelf = self as? AnyEquatableObservableProtocol {
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

  internal func setValue(_ newValue: Value) {
    apply(newValue)
    performComputation(force: true)
  }
}
/*
extension MutableComputedProperty: AnyEquatableObservablePropertyProtocol where Value: Equatable {
  func valuesEqual(_ value1: Any?, _ value2: Any?) -> Bool {
    if value1 == nil && value2 == nil {
      return true
    } else if let value1 = value1 as? Value, let value2 = value2 as? Value {
      return value1 == value2
    } else {
      return false
    }
  }
}*/