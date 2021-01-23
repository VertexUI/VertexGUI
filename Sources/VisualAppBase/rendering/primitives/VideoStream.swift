import GfxMath
import Events
import Swim

open class VideoStream: EventfulObject {
  open var size: ISize2 {
    fatalError("size not implemented")
  }

  public let onSizeChanged = EventHandlerManager<ISize2>()

  public var state: State = .paused

  public init() {}

  deinit {
    removeAllEventHandlers()
  }

  open func getCurrentFrame() -> Frame? {
    fatalError("getCurrentFrame() not implemented")
  }

  open func getCurrentFrameImageRGBA() -> Image? {
    if let frame = getCurrentFrame() {
      return Swim.Image<Swim.RGB, UInt8>(width: size.width, height: size.height, rgb: frame.data).toRGBA(with: 255)
    }
    return nil
  }

  open class Frame {
    public let data: [UInt8]

    public init(_ data: [UInt8]) {
      self.data = data
    }
  }

  public enum State {
    case playing, paused
  }
}