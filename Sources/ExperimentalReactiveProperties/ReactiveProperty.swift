import Events

public protocol ReactiveProperty {
  associatedtype Value

  var onChanged: EventHandlerManager<(old: Value, new: Value)> { get }
}