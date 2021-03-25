import GfxMath

open class CpuBufferDrawingSurface: DrawingSurface {
  public let size: DSize2
  public var resolution: Double {
    fatalError("not implemented")
  } // implement?
  public var buffer: UnsafeMutablePointer<Int8>

  public init(size: ISize2) {
    self.size = DSize2(size)
    self.buffer = UnsafeMutablePointer.allocate(capacity: size.width * size.height * 4)
  }

  public func getDrawingContext() -> DrawingContext {
    fatalError("change API, this does probably not make much sense; call it on window directly! (maybe)")
  }
}