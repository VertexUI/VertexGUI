import Events

public class BiDirectionalPropertyBinding: PropertyBindingProtocol, EventfulObject {
  private var handlerRemovers = [() -> ()]()
  private var unregisterFunctions = [() -> ()]()

  public let onDestroyed = EventHandlerManager<Void>()
  public private(set) var destroyed: Bool = false

  public init<P1: MutablePropertyProtocol, P2: MutablePropertyProtocol>(_ property1: P1, _ property2: P2) where P1.Value == P2.Value, P1.Value: Equatable {
    handlerRemovers.append(property1.onChanged { [unowned property1, property2] _ in
      if !property2.hasValue || property2.value != property1.value {
        property2.value = property1.value
      }
    })
    handlerRemovers.append(property1.onHasValueChanged { [unowned property1, property2] in
      if !property2.hasValue || property2.value != property1.value {
        property2.value = property1.value
      }
    })
    handlerRemovers.append(property1.onDestroyed { [unowned self] in
      destroy()
    })
    handlerRemovers.append(property2.onChanged { [unowned property1, property2] _ in
      if !property1.hasValue || property1.value != property2.value {
        property1.value = property2.value
      }
    })
    handlerRemovers.append(property2.onHasValueChanged { [unowned property1, property2] in
      if !property1.hasValue || property1.value != property2.value {
        property1.value = property2.value
      }
    })
    handlerRemovers.append(property2.onDestroyed { [unowned self] in
      destroy()
    })

    unregisterFunctions.append(property1.registerBinding(self))
    unregisterFunctions.append(property2.registerBinding(self))
  }

  public func destroy() {
    if destroyed {
      return
    }
    for remove in handlerRemovers {
      remove()
    }
    for unregister in unregisterFunctions {
      unregister()
    }
    destroyed = true
    onDestroyed.invokeHandlers(())
    removeAllEventHandlers()
  }

  deinit {
    destroy()
  }
}