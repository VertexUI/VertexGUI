import Events

private var reactivePropertyIds = [ObjectIdentifier: UInt]()
private var nextReactivePropertyId: UInt = 0

public protocol AnyReactiveProperty: class {
  /** used for debugging */
  var id: UInt { get }

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
  public var id: UInt {
    if reactivePropertyIds[ObjectIdentifier(self)] == nil {
      reactivePropertyIds[ObjectIdentifier(self)] = nextReactivePropertyId
      nextReactivePropertyId += 1
    } 
    return reactivePropertyIds[ObjectIdentifier(self)]!
  }

  public func registerBinding(_ binding: PropertyBindingProtocol) -> () -> () {
    registeredBindings.append(binding)
    return { [weak self, weak binding] in
      if let self = self, let binding = binding {
        self.registeredBindings.removeAll { $0 === binding }
      }
    }
  }
}