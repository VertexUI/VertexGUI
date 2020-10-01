public class RenderObjectBus {

    public private(set) var onMessage = EventHandlerManager<Message>()

    public init() {}

    public func publish(_ message: Message) {

        onMessage.invokeHandlers(message)
    }

    public enum Message {

        case TransitionStarted, TransitionEnded
    }
}