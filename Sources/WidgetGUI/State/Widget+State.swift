extension Widget {
  @propertyWrapper
  public class State<V>: InternalMutableReactiveProperty {
    public typealias Value = V
    public typealias Output = Value
    public typealias Failure = Never

    public var value: Value {
      get { wrappedValue }
      set { wrappedValue = newValue }
    }
    public var wrappedValue: Value {
      didSet {
        notifyChange()
      }
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

    var subscriptions: State<V>.Subscriptions = []

    public init(wrappedValue: Value) {
      self.wrappedValue = wrappedValue
    }
  }
}