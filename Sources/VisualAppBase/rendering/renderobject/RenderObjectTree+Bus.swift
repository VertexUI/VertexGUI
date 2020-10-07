extension RenderObjectTree {

    public class Bus<Message> {

        public private(set) var onMessage = EventHandlerManager<Message>()

        public init() {}

        public func publish(_ message: Message) {

            onMessage.invokeHandlers(message)
        }
    }

    public struct RootwardMessage {

        public var sender: RenderObject

        public var content: RootwardMessageContent
    }
    
    public enum RootwardMessageContent {

        case TransitionStarted, TransitionEnded, ChildrenUpdated
    }

    public enum LeafwardMessage {

        case Tick
    }
}