//

//

import Foundation
import CustomGraphicsMath

open class Window {
    open var id: Int {
        get {
            return -1
        }
    }
    open var size: DSize2
    open var background: Color
    open var focused = false {
        didSet {
            do {
                try onFocusChange.invokeHandlers(focused)
            } catch {
                print("Error while calling onFocusChange handlers.")
            }
        }
    }

    public var onMouse = EventHandlerManager<RawMouseEvent>()
    public var onKey = EventHandlerManager<KeyEvent>()
    public var onText = EventHandlerManager<TextEvent>()
    public var onResize = EventHandlerManager<DSize2>()
    public var onFocusChange = EventHandlerManager<Bool>()
    public var onClose = EventHandlerManager<Void>()

    // TODO: maybe can remove background color
    public required init(background: Color, size: DSize2) throws {
        self.background = background
        self.size = size
    }

    open func updateSize() throws {
        try onResize.invokeHandlers(size)
    }

    open func updateContent() {
        fatalError("updateContent() not implemented.")
    }

    open func close() {
        fatalError("close() not implemented.")
    }
}   