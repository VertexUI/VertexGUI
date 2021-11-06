import Events

/// Define a PublishingEventManager attribute of a Widget as a publically accessible signal,
/// so that it can be used with `.on(\.$signalName) { execute... }`
@propertyWrapper
public class Signal<V> {
  public typealias Value = V

  public var wrappedValue: PublishingEventManager<V>

  public var projectedValue: Signal<V> {
    self
  }

  public init(wrappedValue: PublishingEventManager<V>) {
    self.wrappedValue = wrappedValue
  }
}