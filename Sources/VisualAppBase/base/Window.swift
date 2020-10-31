//

//

import CustomGraphicsMath
import Foundation

open class Window {
  open var id: Int {
    return -1
  }

  public let options: Options

  open var size: DSize2
  public var drawableSize: DSize2 = DSize2(0, 0)

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
  public required init(options: Options) throws {
    self.options = options
    self.size = options.initialSize
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

extension Window {
  public enum InitialPosition {
    case Centered
    case Defined(point: IPoint2)
  }

  public struct Options {
    public var title: String?
    public var initialSize: DSize2
    public var initialPosition: InitialPosition
    public var background: Color
    public var borderless: Bool

    public init(
      title: String? = nil,
      initialSize: DSize2 = DSize2(800, 600),
      initialPosition: InitialPosition = .Centered,
      background: Color = .Grey,
      borderless: Bool = false) {
        self.title = title
        self.initialSize = initialSize
        self.initialPosition = initialPosition
        self.background = background
        self.borderless = borderless
    }
  }
}
