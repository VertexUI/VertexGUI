import Events

extension Bus {
  public class MessageBuffer: EventfulObject {
    public private(set) var messages: [Message] = []

    public let onMessageAdded = EventHandlerManager<Message>()
    public let onDestroy = EventHandlerManager<Void>()

    public init() {}

    public func sink(_ message: Message) {
      messages.append(message)
      onMessageAdded.invokeHandlers(message)
    }

    public func destroy() {
      onDestroy.invokeHandlers()
      removeAllEventHandlers()
    }
  }
}