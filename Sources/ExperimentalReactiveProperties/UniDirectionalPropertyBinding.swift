import Events

public class UniDirectionalPropertyBinding: PropertyBindingProtocol {
  public let onDestroyed = EventHandlerManager<Void>()

  private let removeSourceHandler: () -> ()
  
  private let _update: () -> ()

  internal init<Source: ReactiveProperty, Sink: MutablePropertyProtocol>(source: Source, sink: Sink) where Source.Value == Sink.Value {
    removeSourceHandler = source.onChanged {
      sink.value = $0.new
    }
    _update = {
      sink.value = source.value
    }
  }

  public func update() {
    _update()
  }

  public func destroy() {
    removeSourceHandler()
    onDestroyed.invokeHandlers(())
  }
}