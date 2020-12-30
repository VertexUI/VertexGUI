import Events

public protocol AnyReactiveProperty: class {
  var onAnyChanged: EventHandlerManager<(old: Any, new: Any)> { get }

  /** Flag to indicate whether the value of the property has been initialized and can be read. */
  var hasValue: Bool { get }
  
  var onHasValueChanged: EventHandlerManager<Void> { get }

  var onDestroyed: EventHandlerManager<Void> { get }

  /** used to keep bindings in memory, prevent early deinitialization */
  var registeredBindings: [PropertyBindingProtocol] { get set }
  func registerBinding(_ binding: PropertyBindingProtocol) -> () -> ()
}

extension AnyReactiveProperty {
  public func registerBinding(_ binding: PropertyBindingProtocol) -> () -> () {
    registeredBindings.append(binding)
    return { [unowned self] in
      registeredBindings.removeAll { $0 === binding }
    }
  }
}