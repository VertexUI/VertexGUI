import CXShim

public class ReactivePropertyProjection<V>: Publisher {
  public typealias Value = V
  public typealias Output = V
  public typealias Failure = Never

  private let getImmutable: () -> ImmutableBinding<Value>
  private let receiveSubscriber: (AnySubscriber<Value, Never>) -> ()

  public var immutable: ImmutableBinding<Value> {
    getImmutable()
  }

  init(getImmutable: @escaping () -> ImmutableBinding<Value>, receiveSubscriber: @escaping (AnySubscriber<Value, Never>) -> ()) {
    self.getImmutable = getImmutable
    self.receiveSubscriber = receiveSubscriber
  }

  public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
    receiveSubscriber(AnySubscriber(subscriber))
  }
}

public class MutableReactivePropertyProjection<V>: ReactivePropertyProjection<V> {
  private let getMutable: () -> MutableBinding<Value>

  public var mutable: MutableBinding<Value> {
    getMutable()
  }

  init(getImmutable: @escaping () -> ImmutableBinding<Value>, getMutable: @escaping () -> MutableBinding<Value>, receiveSubscriber: @escaping (AnySubscriber<Value, Never>) -> ()) {
    self.getMutable = getMutable
    super.init(getImmutable: getImmutable, receiveSubscriber: receiveSubscriber)
  }
}