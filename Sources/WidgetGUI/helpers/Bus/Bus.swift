import Events

public class Bus<M> {
  public typealias Message = M

  private var sinks: [MessageBuffer] = []
  public let onMessage = EventHandlerManager<Message>()

  public func publish(_ message: Message) {
    if onMessage.handlers.count == 0 && sinks.count == 0{
      //print("warn: message", message, "got dropped")
    } else {
      for sink in sinks { sink.sink(message) }
      onMessage.invokeHandlers(message)
    }
  }

  public func pipe(_ sink: MessageBuffer) {
    sinks.append(sink)
    _ = sink.onDestroy { [unowned self, unowned sink] in
      sinks.removeAll { $0 === sink }
    }
  }
}