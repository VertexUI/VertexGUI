extension RenderObject {
    public class Bus {
        public private(set) var onUpwardMessage = EventHandlerManager<UpwardMessage>()
        public private(set) var onDownwardMessage = EventHandlerManager<DownwardMessage>()

        public init() {}

        public func up(_ message: UpwardMessage) {
            onUpwardMessage.invokeHandlers(message)
        }

        public func down(_ message: DownwardMessage) {
            onDownwardMessage.invokeHandlers(message)
        }
    }

    public struct UpwardMessage {
        public var sender: RenderObject
        public var content: UpwardMessageContent
    }
    
    public enum UpwardMessageContent {
        case invalidateCache, transitionStarted, transitionEnded, addUncachable, removeUncachable, childrenUpdated
    }

    public enum DownwardMessage {
        case Tick(tick: Tick)
    }
}