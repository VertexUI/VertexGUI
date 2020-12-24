import Events

public protocol AnyReactiveProperty: class {
  var onAnyChanged: EventHandlerManager<(old: Any, new: Any)> { get }
}