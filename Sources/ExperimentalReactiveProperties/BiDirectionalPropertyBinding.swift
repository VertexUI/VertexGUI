public class BiDirectionalPropertyBinding {

  private var handlerRemovers = [() -> ()]()
  private var destroyed: Bool = false

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
      if !property1.hasValue || (property1.value != property2.value) {
        property1.value = property2.value
      }
    })
    handlerRemovers.append(property2.onHasValueChanged {
      if !property1.hasValue || (property1.value != property2.value) {
        property1.value = property2.value
      }
    })
    handlerRemovers.append(property2.onDestroyed { [unowned self] in
      destroy()
    })
  }

  public func destroy() {
    if destroyed {
      return
    }
    destroyed = true
  }

  deinit {
    destroy()
  }
}