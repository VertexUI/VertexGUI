extension Widget {
  @propertyWrapper
  public class State<V>: ExperimentalInternalMutableReactiveProperty {
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

    lazy public var projectedValue = Experimental.MutableReactivePropertyProjection<Value>(getImmutable: { [unowned self] in
      Experimental.ImmutableBinding(self, get: {
        $0
      })
    }, getMutable: { [unowned self] in
      Experimental.MutableBinding(self, get: {
        $0
      }, set: {
        $0
      })
    })

    var subscriptions: State<V>.Subscriptions = []

    public init(wrappedValue: Value) {
      self.wrappedValue = wrappedValue
    }
  }
}