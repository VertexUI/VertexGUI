public class EventHandlerManager<Data> {
    public typealias Handler = (Data) throws -> Void
    public typealias UnregisterCallback = () -> Void
    private var handlers = [Int: Handler]()
    private var nextHandlerId = 0

    public init() {
    }

    public func callAsFunction(_ handler: @escaping Handler) -> UnregisterCallback {
        addHandler(handler)
    }

    public func addHandler(_ handler: @escaping Handler) -> UnregisterCallback {
        let currentHandlerId = nextHandlerId
        handlers[currentHandlerId] = handler
        nextHandlerId += 1
        return {
            self.handlers.removeValue(forKey: currentHandlerId)
        }
    }

    public func invokeHandlers(_ data: Data) throws {
        for handler in handlers.values {
            try handler(data)
        }
    }
}
