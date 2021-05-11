import CXShim

@propertyWrapper
public class MutableBinding<V>: InternalMutableReactiveProperty  {
  public typealias Value = V
  public typealias Output = Value
  public typealias Failure = Never

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

  lazy public var projectedValue = MutableReactivePropertyProjection<Value>(getImmutable: { [unowned self] in
    ImmutableBinding(self, get: {
      $0
    })
  }, getMutable: { [unowned self] in
    MutableBinding(self, get: {
      $0
    }, set: {
      $0
    })
  }, receiveSubscriber: { [unowned self] in
    self.receive(subscriber: $0)
  })

  var subscriptions: MutableBinding<V>.Subscriptions = []

  private var dependencySubscription: AnyCancellable?

  public init<Dependency: MutableReactiveProperty>(
    _ dependency: Dependency,
    get _get: @escaping (Dependency.Value) -> Value,
    set _set: @escaping (Value) -> Dependency.Value) where Dependency.Failure == Never {
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