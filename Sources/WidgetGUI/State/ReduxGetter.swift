import VisualAppBase

internal protocol ReduxGetterMarkerProtocol {
  var dependencies: [AnyObservableProperty] { get set }
  var anyObservableState: Any? { get set }
}

@propertyWrapper
public class ReduxGetter<V, State>: ObservableProperty<V>, ReduxGetterMarkerProtocol {
  public typealias Value = V
  public typealias Enclosing = ReduxGetters<State>

  private var _value: Value?
  override public var value: Value {
    if _value == nil {
      _value = compute(observableState.value)
    }
    return _value!
  }

  override public var wrappedValue: Value {
    value
  }

  override public var projectedValue: ObservableProperty<V> {
    self
  }

  public var compute: (_ state: State) -> Value {
    didSet {
      _value = nil
      onChanged.invokeHandlers(value)
    }
  }

  internal var observableState: ObservableProperty<State> {
    anyObservableState as! ObservableProperty<State>
  }
  internal var anyObservableState: Any? = nil

  public var dependencies: [AnyObservableProperty] {
    didSet {
      removeDependencyHandlers()
      registerDependencyHandlers()
    }
  }
  private var dependencyChangedHandlerRemovers = [() -> ()]()

  // TODO: automatically track dependencies by registering through a static global variable in first call of compute
  public init(compute: @escaping (_ state: State) -> Value) {
    self.compute = compute
    self.dependencies = []
    super.init()
    registerDependencyHandlers()
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