import Events

public protocol AnyReactiveProperty: class {
  var onAnyChanged: EventHandlerManager<(old: Any, new: Any)> { get }

  /** Flag to indicate whether the value of the property has been initialized and can be read. */
  var hasValue: Bool { get }
  
  var onHasValueChanged: EventHandlerManager<Void> { get }
}