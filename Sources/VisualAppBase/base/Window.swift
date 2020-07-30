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

    public var onKey = ThrowingEventHandlerManager<KeyEvent>()
    public var onMouse = ThrowingEventHandlerManager<RawMouseEvent>()
    public var onResize = ThrowingEventHandlerManager<DSize2>()
    public var onFocusChange = ThrowingEventHandlerManager<Bool>()
    public var onClose = ThrowingEventHandlerManager<Void>()

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
}   