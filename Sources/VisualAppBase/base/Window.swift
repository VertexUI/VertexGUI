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

    public var onKey = EventHandlerManager<KeyEvent>()
    public var onMouse = EventHandlerManager<MouseEvent>()
    public var onResize = EventHandlerManager<DSize2>()
    public var onFocusChange = EventHandlerManager<Bool>()

    // TODO: maybe can remove background color
    public init(background: Color) throws {
        self.background = background
        self.size = DSize2(0,0)
    }

    open func updateSize() throws {
        try onResize.invokeHandlers(size)
    }
}   