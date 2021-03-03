import CombineX

public protocol ExperimentalReactiveProperty: AnyObject, Publisher {
  associatedtype Value

  var value: Value { get }
}

extension ExperimentalReactiveProperty {
  public typealias Output = Value
  public typealias Failure = Never
}

internal protocol ExperimentalInternalReactiveProperty: ExperimentalReactiveProperty {
  var subscriptions: Subscriptions { get set }
}

extension ExperimentalInternalReactiveProperty {
  typealias Subscriptions = [ExperimentalReactivePropertySubscription<Value>]

  internal func notifyChange() {
    for subscription in subscriptions {
      subscription.receive(value)
    }
  }

  public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
    let subscription = ExperimentalReactivePropertySubscription(subscriber: AnySubscriber(subscriber))
    subscriptions.append(subscription)
    subscriber.receive(subscription: subscription)
    subscription.receive(value)
  }
}

internal class ExperimentalReactivePropertySubscription<V>: Subscription {
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

extension Experimental {
  public class AnyReactiveProperty<V>: ExperimentalInternalReactiveProperty {
    public typealias Value = V

    public var value: Value {
      didSet {
        notifyChange()
      }
    }
    
    var ownedWrapped: AnyObject
    var wrappedSubscription: AnyCancellable?

    var subscriptions: AnyReactiveProperty<V>.Subscriptions = []

    public init<P: ExperimentalReactiveProperty>(_ wrapped: P) where P.Value == V {
      self.value = wrapped.value
      self.ownedWrapped = wrapped
      wrappedSubscription = wrapped.sink(receiveValue: { [unowned self] in
        value = $0
      })
    }
  }
}