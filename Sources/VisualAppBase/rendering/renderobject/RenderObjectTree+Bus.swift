extension RenderObjectTree {

    public class Bus<Message> {

        public private(set) var onMessage = EventHandlerManager<Message>()

        public init() {}

        public func publish(_ message: Message) {

            onMessage.invokeHandlers(message)
        }
    }

    public enum RootwardMessage {

        case TransitionStarted, TransitionEnded
    }

    public enum LeafwardMessage {

        case Tick
    }
}