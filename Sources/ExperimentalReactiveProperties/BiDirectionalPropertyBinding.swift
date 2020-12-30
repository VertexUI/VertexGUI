public class BiDirectionalPropertyBinding: PropertyBindingProtocol {

  private var handlerRemovers = [() -> ()]()
  private var unregisterFunctions = [() -> ()]()
  public private(set) var destroyed: Bool = false

  public init<P1: MutablePropertyProtocol, P2: MutablePropertyProtocol>(_ property1: P1, _ property2: P2) where P1.Value == P2.Value, P1.Value: Equatable {
    handlerRemovers.append(property1.onChanged { _ in
      if !property2.hasValue || property2.value != property1.value {
        property2.value = property1.value
      }
    })
    handlerRemovers.append(property1.onHasValueChanged {
      if !property2.hasValue || property2.value != property1.value {
        property2.value = property1.value
      }
    })
    handlerRemovers.append(property1.onDestroyed { [unowned self] in
      destroy()
    })
    handlerRemovers.append(property2.onChanged { _ in
      if !property1.hasValue || property1.value != property2.value {
        property1.value = property2.value
      }
    })
    handlerRemovers.append(property2.onHasValueChanged {
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
  }

  deinit {
    destroy()
  }
}