import GfxMath

public class VideoStream {
  public let size: ISize2
  public var currentFrame: UnsafeMutableBufferPointer<UInt8>? = nil

  public init(size: ISize2) {
    self.size = size
  }
}