import Events

public class UniDirectionalPropertyBinding: PropertyBindingProtocol {
  private var handlerRemovers = [() -> ()]()
  private var unregisterFunctions = [() -> ()]()

  private var destroyed: Bool = false
  public let onDestroyed = EventHandlerManager<Void>()

  internal init<Source: ReactiveProperty, Sink: MutablePropertyProtocol>(source: Source, sink: Sink) where Source.Value == Sink.Value {    
    handlerRemovers.append(source.onChanged {
      sink.value = $0.new
    })
    handlerRemovers.append(source.onHasValueChanged {
      sink.value = source.value
    })
    handlerRemovers.append(source.onDestroyed { [unowned self] in
      destroy()
    })
    handlerRemovers.append(sink.onDestroyed { [unowned self] in
      destroy()
    })

    if source.hasValue {
      sink.value = source.value
    }
    
    unregisterFunctions.append(source.registerBinding(self))
    unregisterFunctions.append(sink.registerBinding(self))
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
  }

  deinit {
    destroy()
  }
}