import GfxMath

open class CpuBufferDrawingSurface: DrawingSurface {
  public var size: ISize2
  public var resolution: Double {
    fatalError("not implemented")
  } // implement?
  public var buffer: UnsafeMutableBufferPointer<UInt8>

  public init(size: ISize2) {
    self.size = size
    self.buffer = UnsafeMutableBufferPointer.allocate(capacity: size.width * size.height * 4)
  }

  public func getDrawingContext() -> DrawingContext {
    fatalError("change API, this does probably not make much sense; call it on window directly! (maybe)")
  }
}