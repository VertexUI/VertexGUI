import CombineX

extension Experimental {
  @propertyWrapper
  public class MutableBinding<V>: ExperimentalInternalReactiveProperty  {
    public typealias Value = V

    public var value: Value {
      get {
        _get()
      }
      set {
        _set(newValue)
      }
    }

    private let _get: () -> Value
    private let _set: (Value) -> ()

    public var wrappedValue: Value {
      get { value }
      set { value = newValue }
    }

    lazy public var projectedValue = Experimental.MutableReactivePropertyProjection<Value>(getImmutable: { [unowned self] in
      Experimental.ImmutableBinding(self, get: {
        $0
      })
    }, getMutable: { [unowned self] in
      self
    })

    var subscriptions: MutableBinding<V>.Subscriptions = []

    private var dependencySubscription: AnyCancellable?

    public init<DependencyValue, Dependency: Widget.State<DependencyValue>>(
      _ dependency: Dependency,
      get _get: @escaping (DependencyValue) -> Value,
      set _set: @escaping (Value) -> DependencyValue) {
        self._get = { [dependency] in
          _get(dependency.value)
        }
        self._set = { [dependency] in
          dependency.value = _set($0)
        }

        dependencySubscription = dependency.sink { [unowned self] _ in
          notifyChange()
        }
    }
  }
}