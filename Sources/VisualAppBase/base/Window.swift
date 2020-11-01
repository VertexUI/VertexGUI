//

//

import CustomGraphicsMath
import Foundation

open class Window {
  open var id: Int {
    return -1
  }

  public let options: Options

  private var _size: DSize2 = .zero
  open var size: DSize2 {
    get {
      if sizeInvalid {
        _size = readSize()
        sizeInvalid = false
      }
      return _size
    }
    set {
      applySize(newValue)
      _size = newValue
    }
  }
  public private(set) var sizeInvalid = false

  private var _drawableSize: DSize2 = .zero
  public var drawableSize: DSize2 {
    if drawableSizeInvalid {
      _drawableSize = readDrawableSize()
      drawableSizeInvalid = false
    }
    return _drawableSize
  }
  public private(set) var drawableSizeInvalid = false

  private var _position: DPoint2 = .zero
  open var position: DPoint2 {
    get {
      if positionInvalid {
        _position = readPosition()
        positionInvalid = false
      }
      return _position
    }
    set {
      applyPosition(newValue)
      _position = newValue
    }
  }
  public private(set) var positionInvalid = false

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
  public var onSizeChanged = EventHandlerManager<DSize2>()
  public var onPositionChanged = EventHandlerManager<DPoint2>()
  public var onFocusChange = EventHandlerManager<Bool>()
  public var onClose = EventHandlerManager<Void>()

  // TODO: maybe can remove background color
  public required init(options: Options) throws {
    self.options = options
  }

  public func invalidateSize() {
    sizeInvalid = true
    drawableSizeInvalid = true
    onSizeChanged.invokeHandlers(size)
  }

  public func invalidatePosition() {
    positionInvalid = true
    onPositionChanged.invokeHandlers(position)
  }

  open func readSize() -> DSize2 {
    fatalError("readSize() not implemented")
  }

  open func readDrawableSize() -> DSize2 {
    fatalError("readDrawableSize() not implemented")
  }

  open func readPosition() -> DPoint2 {
    fatalError("readPosition() not implemented")
  }

  open func applySize(_ newSize: DSize2) {
    fatalError("applySize(:) not implemented")
  }
  
  open func applyPosition(_ newPosition: DPoint2) {
    fatalError("applyPosition(:) not implemented")
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
    case Defined(_ point: DPoint2)
  }

  public struct Options {
    public var title: String?
    public var initialSize: DSize2
    public var initialPosition: InitialPosition
    public var background: Color
    public var borderless: Bool
    public var initialShown: Bool

    public init(
      title: String? = nil,
      initialSize: DSize2 = DSize2(800, 600),
      initialPosition: InitialPosition = .Centered,
      background: Color = .Grey,
      borderless: Bool = false,
      initialShown: Bool = true) {
        self.title = title
        self.initialSize = initialSize
        self.initialPosition = initialPosition
        self.background = background
        self.borderless = borderless
        self.initialShown = initialShown
    }
  }
}
