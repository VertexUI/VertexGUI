import CombineX

extension Experimental {
  @propertyWrapper
  public class ImmutableBinding<O>: ExperimentalInternalReactiveProperty/*, Binding<V>*/ {
    public typealias Value = O

    public var value: Value {
      wrappedValue
    }
    public var wrappedValue: Value {
      _get()
    }
    private let _get: () ->Value 

    lazy public var projectedValue = Experimental.ReactivePropertyProjection<Value>(getImmutable: { [unowned self] in
      return Experimental.ImmutableBinding(self, get: {
        $0
      })
    })
    var subscriptions: ImmutableBinding<Value>.Subscriptions = []

    private var dependencySubscription: AnyCancellable?

    public init<DependencyValue, Dependency: ExperimentalReactiveProperty>(
      _ dependency: Dependency,
      get _get: @escaping (DependencyValue) -> Value) where Dependency.Value == DependencyValue {
        self._get = { [dependency] in
          _get(dependency.value)
        }

        dependencySubscription = dependency.sink { [unowned self] _ in
          notifyChange()
        }
    }
  }
}