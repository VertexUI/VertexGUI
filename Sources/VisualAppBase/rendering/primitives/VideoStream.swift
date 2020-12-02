import GfxMath

open class VideoStream {
  public let size: ISize2

  public var state: State = .paused

  public init(size: ISize2) {
    self.size = size
  }

  open func getCurrentFrame() -> Frame? {
    fatalError("getCurrentFrame() not implemented")
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