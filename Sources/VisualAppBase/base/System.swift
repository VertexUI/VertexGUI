open class System<W: Window, R: Renderer> {
    public typealias Window = W
    public typealias Renderer = R

    public var keyStates = Key.allCases.reduce(into: [Key: Bool]()) {
        $0[$1] = false
    }

    public var cursorRequests: [UInt64: Cursor] = [:] // TODO: maybe handle first come first or z index
    public var nextCursorRequestId: UInt64 = 0
    public var onFrame = EventHandlerManager<Int>()

    public init() throws {

    }

    open func newWindow() throws -> W {
        fatalError("newWindow() not implemented.")
    }

    open func requestCursor(_ cursor: Cursor) throws -> UInt64 {
        let id = nextCursorRequestId
        cursorRequests[id] = cursor
        nextCursorRequestId += 1
        try updateCursor()
        return id
    }

    open func dropCursorRequest(id: UInt64) throws {
        cursorRequests.removeValue(forKey: id)
        try updateCursor()
    }

    open func updateCursor() throws {
        fatalError("updateCursor not implemented.")
    }

    open func mainLoop() throws {
        fatalError("mainLoop not implemented.")
    }

    /*public func eventLoop() throws {}

    public func eventLoop() throws {}*/
}