import Events

public protocol AnyReactiveProperty {
  var onAnyChanged: EventHandlerManager<(old: Any, new: Any)> { get }
}