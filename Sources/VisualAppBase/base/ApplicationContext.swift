//

//

import Foundation
import CustomGraphicsMath

public class ApplicationContext<S: System, W: Window, R: Renderer> {
    public var mousePosition = DPoint2(0,0)
   // public var cursorRequests: [UInt64: Cursor] = [:] // TODO: maybe handle first come first or z index
    //public var nextCursorRequestId: UInt64 = 0
    //public var onCursorRequestsUpdated = ThrowingEventHandlerManager<Void>()
    public var system: S
    public var window: W
    public var renderer: R

    public init(system: S, window: W, renderer: R) {
        self.system = system
        self.window = window
        self.renderer = renderer
    }

    /*public func requestCursor(_ cursor: Cursor) throws -> UInt64 {
        let id = nextCursorRequestId
        cursorRequests[id] = cursor
        nextCursorRequestId += 1
        try onCursorRequestsUpdated.invokeHandlers(Void())
        return id
    }

    public func dropCursorRequest(id: UInt64) throws {
        cursorRequests.removeValue(forKey: id)
        try onCursorRequestsUpdated.invokeHandlers(Void())
    }*/
}