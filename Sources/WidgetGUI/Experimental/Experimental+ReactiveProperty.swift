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
  var subscribers: [AnySubscriber<Value, Never>] { get set }
}

extension ExperimentalInternalReactiveProperty {
  typealias Subscribers = [AnySubscriber<Value, Never>]

  internal func notifyChange() {
    for subscriber in subscribers {
      subscriber.receive(value)
    }
  }

  public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
    subscribers.append(AnySubscriber(subscriber))
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

    var subscribers: AnyReactiveProperty<V>.Subscribers = []

    public init<P: ExperimentalReactiveProperty>(_ wrapped: P) where P.Value == V {
      self.value = wrapped.value
    }
  }
}