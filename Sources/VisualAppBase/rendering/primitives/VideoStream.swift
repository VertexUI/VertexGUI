import GfxMath

open class VideoStream {
  public let size: ISize2

  public init(size: ISize2) {
    self.size = size
  }

  open func getCurrentFrame() -> UnsafeMutableBufferPointer<UInt8>? {
    fatalError("getCurrentFrame() not implemented")
  }
}