import CombineX

extension Experimental {
  @propertyWrapper
  public class ImmutableBinding<V>: ExperimentalInternalReactiveProperty/*, Binding<V>*/ {
    public typealias Value = V

    public var value: Value {
      wrappedValue
    }
    public var wrappedValue: Value {
      _get()
    }
    private let _get: () -> Value

    public var projectedValue: ImmutableBinding<V> {
      self
    }

    var subscriptions: ImmutableBinding<V>.Subscriptions = []

    private var dependencySubscription: AnyCancellable?

    public init<P: ExperimentalReactiveProperty>(_ dependency: P, get _get: @escaping (P) -> Value) where P.Value == Value {
      self._get = { [weak dependency] in
        guard let dependency = dependency else {
          fatalError("@ImmutableBinding tried to read dependency after dependency was deallocated.")
        }
        return _get(dependency)
      }

      dependencySubscription = dependency.sink(receiveValue: { [unowned self] _ in
        notifyChange()
      })
    }
  }
}