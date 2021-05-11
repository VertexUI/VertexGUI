import CXShim

@propertyWrapper
public class ImmutableBinding<O>: InternalReactiveProperty {
  public typealias Value = O
  public typealias Output = Value
  public typealias Failure = Never

  public var value: Value {
    wrappedValue
  }
  public var wrappedValue: Value {
    _get()
  }
  private let _get: () ->Value 

  lazy public var projectedValue = ReactivePropertyProjection<Value>(getImmutable: { [unowned self] in
    return ImmutableBinding(self, get: {
      $0
    })
  }, receiveSubscriber: { [unowned self] in
    self.receive(subscriber: $0)
  })
  var subscriptions: ImmutableBinding<Value>.Subscriptions = []

  private var dependencySubscription: AnyCancellable?

  public init<DependencyValue, Dependency: ReactiveProperty>(
    _ dependency: Dependency,
    get _get: @escaping (DependencyValue) -> Value) where Dependency.Value == DependencyValue, Dependency.Failure == Never {
      self._get = { [dependency] in
        _get(dependency.value)
      }

      dependencySubscription = dependency.sink { [unowned self] _ in
        notifyChange()
      }
  }

  public init(get _get: @escaping () -> Value) {
    self._get = _get
  }
}