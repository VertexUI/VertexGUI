extension Experimental {
  public class ReactivePropertyProjection<V> {
    public typealias Value = V

    private let getImmutable: () -> ImmutableBinding<Value>

    public var immutable: ImmutableBinding<Value> {
      getImmutable()
    }

    init(getImmutable: @escaping () -> ImmutableBinding<Value>) {
      self.getImmutable = getImmutable
    }
  }

  public class MutableReactivePropertyProjection<V>: ReactivePropertyProjection<V> {
    private let getMutable: () -> MutableBinding<Value>

    public var mutable: MutableBinding<Value> {
      getMutable()
    }

    init(getImmutable: @escaping () -> Experimental.ImmutableBinding<Value>, getMutable: @escaping () -> Experimental.MutableBinding<Value>) {
      self.getMutable = getMutable
      super.init(getImmutable: getImmutable)
    }
  }
}