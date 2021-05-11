import CXShim

public protocol ReactiveProperty: AnyObject, Publisher {
  associatedtype Value

  var value: Value { get }
}

internal protocol ErasedInternalReactiveProperty {
  func notifyChange()
}

internal class AnyErasedInternalReactiveProperty: ErasedInternalReactiveProperty {
  let _notifyChange: () -> ()

  let wrapped: Any

  init<T: ErasedInternalReactiveProperty>(wrapping wrapped: T) {
    self._notifyChange = wrapped.notifyChange
    self.wrapped = wrapped
  }

  func notifyChange() {
    _notifyChange()
  }
}

internal protocol InternalReactiveProperty: ReactiveProperty, ErasedInternalReactiveProperty {
  var subscriptions: Subscriptions { get set }
}

extension InternalReactiveProperty {
  typealias Subscriptions = [ReactivePropertySubscription<Value>]

  internal func notifyChange() {
    for subscription in subscriptions {
      subscription.receive(value)
    }
  }

  public func receive<S: Subscriber>(subscriber: S) where S.Input == Value, S.Failure == Never {
    let subscription = ReactivePropertySubscription(subscriber: AnySubscriber(subscriber))
    subscriptions.append(subscription)
    subscriber.receive(subscription: subscription)
    subscription.receive(value)
  }
}

internal class ReactivePropertySubscription<V>: Subscription {
  private var subscriber: AnySubscriber<V, Never>?

  init(subscriber: AnySubscriber<V, Never>) {
    self.subscriber = subscriber
  }

  func request(_ demand: Subscribers.Demand) {}

  func receive(_ value: V) {
    _ = subscriber?.receive(value)
  }

  func cancel() {
    subscriber = nil
  }
}

public class AnyReactiveProperty<V>: InternalReactiveProperty {
  public typealias Value = V

  public typealias Output = Value
  public typealias Failure = Never

  public var value: Value {
    didSet {
      notifyChange()
    }
  }
  
  var ownedWrapped: AnyObject
  var wrappedSubscription: AnyCancellable?

  var subscriptions: AnyReactiveProperty<V>.Subscriptions = []

  public init<P: ReactiveProperty>(_ wrapped: P) where P.Value == V, P.Output == V, P.Failure == Never {
    self.value = wrapped.value
    self.ownedWrapped = wrapped
    wrappedSubscription = wrapped.sink(receiveValue: { [unowned self] in
      value = $0
    })
  }
}