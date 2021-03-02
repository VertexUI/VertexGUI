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

    public var projectedValue: ImmutableBinding<Value> {
      self
    }

    var subscriptions: ImmutableBinding<Value>.Subscriptions = []

    private var dependencySubscription: AnyCancellable?

    public init<InputValue, P: ExperimentalReactiveProperty>(_ dependency: P, get _get: @escaping (InputValue) -> Value) where P.Value == InputValue {
      self._get = { [dependency] in
        _get(dependency.value)
      }

      dependencySubscription = dependency.sink { [unowned self] _ in
        notifyChange()
      }
    }
  }
}