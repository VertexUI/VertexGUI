//

//

import GfxMath
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
      onSizeChanged.invokeHandlers(newValue)
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
      onPositionChanged.invokeHandlers(newValue)
    }
  }
  public private(set) var positionInvalid = false

  private var _visibility: Visibility = .Shown
  open var visibility: Visibility {
    get {
      if visibilityInvalid {
        _visibility = readVisibility()
        visibilityInvalid = false
      }
      return _visibility
    }
    set {
      applyVisibility(newValue)
      _visibility = newValue
      onVisibilityChanged.invokeHandlers(newValue)
    }
  }
  private var visibilityInvalid = false

  private var _inputFocus = false
  open var inputFocus: Bool {
    get {
      if inputFocusInvalid {
        _inputFocus = readInputFocus()
        inputFocusInvalid = false
      }
      return _inputFocus
    }
    set {
      applyInputFocus(newValue)
      invalidateInputFocus()
    }
  }
  private var inputFocusInvalid = false

  public var frameNeeded = true
  public private(set) var destroyed = false

  public let onBeforeFrame = EventHandlerManager<Window>()
  public let onFrame = EventHandlerManager<Double>()

  public let onMouse = EventHandlerManager<RawMouseEvent>()
  public let onKey = EventHandlerManager<KeyEvent>()
  public let onText = EventHandlerManager<TextEvent>()
  public let onSizeChanged = EventHandlerManager<DSize2>()
  public let onPositionChanged = EventHandlerManager<DPoint2>()
  public let onVisibilityChanged = EventHandlerManager<Visibility>()
  public let onInputFocusChanged = EventHandlerManager<Bool>()
  public let onBeforeClose = EventHandlerManager<Window>()

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

  public func invalidateVisibility() {
    visibilityInvalid = true
    onVisibilityChanged.invokeHandlers(visibility)
  }

  public func invalidateInputFocus() {
    inputFocusInvalid = true
    onInputFocusChanged.invokeHandlers(inputFocus)
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

  open func readVisibility() -> Visibility {
    fatalError("readVisibility() not implemented")
  }

  open func readInputFocus() -> Bool {
    fatalError("readInputFocus() not implemented")
  }

  open func readMouseFocus() -> Bool {
    fatalError("readMouseFocus() not implemented")
  }

  open func applySize(_ newSize: DSize2) {
    fatalError("applySize(:) not implemented")
  }
  
  open func applyPosition(_ newPosition: DPoint2) {
    fatalError("applyPosition(:) not implemented")
  }

  open func applyVisibility(_ newVisibility: Visibility) {
    fatalError("applyVisibility(:) not implemented")
  }

  open func applyInputFocus(_ newFocus: Bool) {
    fatalError("applyInputFocus(:) not implemented")
  }

  open func performFrame(_ deltaTime: Double) {
    onBeforeFrame.invokeHandlers(self)
    if self.frameNeeded {
      self.makeCurrent()
      self.clear()
      onFrame.invokeHandlers(deltaTime)
      self.updateContent()
    }
  }

  open func makeCurrent() {
  }

  open func clear() {
    fatalError("clear() not implemented")
  }

  open func updateContent() {
    fatalError("updateContent() not implemented.")
  }

  open func close() {
    onBeforeClose.invokeHandlers(self)
    destroy()
    destroyed = true
  }

  public final func destroy() {
    let mirror = Mirror(reflecting: self)
    for child in mirror.children {
      if let manager = child.value as? AnyEventHandlerManager {
        manager.removeAllHandlers()
      }
    }
    destroySelf()
  }

  open func destroySelf() {

  }
}

extension Window {
  public enum Visibility {
    case Shown
    case Hidden
  }

  public enum InitialPosition {
    case Centered
    case Defined(_ point: DPoint2)
  }

  public struct Options {
    public var title: String?
    public var initialSize: DSize2
    public var initialPosition: InitialPosition
    public var initialVisibility: Visibility
    public var background: Color
    public var borderless: Bool

    public init(
      title: String? = nil,
      initialSize: DSize2 = DSize2(800, 600),
      initialPosition: InitialPosition = .Centered,
      initialVisibility: Visibility = .Shown,
      background: Color = .Grey,
      borderless: Bool = false) {
        self.title = title
        self.initialSize = initialSize
        self.initialPosition = initialPosition
        self.initialVisibility = initialVisibility
        self.background = background
        self.borderless = borderless
    }
  }
}
