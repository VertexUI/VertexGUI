import OpenCombine

@propertyWrapper
public class ImmutableBinding<O>: InternalReactiveProperty {
  public typealias Value = O

  public var value: Value {
    wrappedValue
  }
  public var wrappedValue: Value {
    _get()
  }
  private let _get: () ->Value 

  lazy public private(set) var publisher = PropertyPublisher<Value>(getCurrentValue: { [weak self] in self?.value })

  lazy public var projectedValue = ReactivePropertyProjection<Value>(getImmutable: { [unowned self] in
    return ImmutableBinding(self, get: {
      $0
    })
  }, publisher: AnyPublisher(publisher))

  private var dependencySubscription: AnyCancellable?

  public init<DependencyValue, Dependency: ReactiveProperty>(
    _ dependency: Dependency,
    get _get: @escaping (DependencyValue) -> Value) where Dependency.Value == DependencyValue {
      self._get = { [dependency] in
        _get(dependency.value)
      }

      dependencySubscription = dependency.publisher.sink { [unowned self] _ in
        notifyChange()
      }
  }

  /// initialize with a plain Publisher from Combine
  public init<P: Publisher>(publisher: P) where P.Output == O, P.Failure == Never {
    fatalError("untested")

    var value: P.Output? = nil

    self._get = { [publisher] in
      value!
    }

    dependencySubscription = publisher.sink { [unowned self] in
      value = $0
      notifyChange()
    }
  }

  public init(get _get: @escaping () -> Value) {
    self._get = _get
  }
}