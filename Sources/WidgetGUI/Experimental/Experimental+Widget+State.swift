extension Widget {
  @propertyWrapper
  public class State<V>: ExperimentalInternalReactiveProperty {
    public typealias Value = V

    public var value: Value {
      get { wrappedValue }
      set { wrappedValue = newValue }
    }
    public var wrappedValue: Value {
      didSet {
        notifyChange()
      }
    }

    lazy public var projectedValue = Projector<Value>(getImmutable: { [unowned self] in
      return Experimental.ImmutableBinding<Value>(self, get: {
        $0.value
      })
    })

    var subscriptions: State<V>.Subscriptions = []

    public init(wrappedValue: Value) {
      self.wrappedValue = wrappedValue
    }

    public class Projector<Value> {
      private let getImmutable: () -> Experimental.ImmutableBinding<Value>

      fileprivate init(getImmutable: @escaping () -> Experimental.ImmutableBinding<Value>) {
        self.getImmutable = getImmutable
      }

      public var immutable: Experimental.ImmutableBinding<Value> {
        getImmutable()
      }
    }
  }
}