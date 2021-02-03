import GfxMath

open class DrawingBackend {
  public init() {}

  open func activate() {

  }

  open func drawRect(rect: DRect, paint: Paint) {
    fatalError("drawRect() not implemented")
  }

  open func drawRoundedRect() {

  }

  open func drawPath() {
    
  }

  /**
  // TODO: maybe the result should be a rect to also have access to the position
  */
  open func measureText(text: String, paint: TextPaint) -> DSize2 {
    fatalError("measureText() not implemented")
  }

  open func drawText(text: String, position: DVec2, paint: TextPaint) {
    fatalError("drawText() not implemented")
  }

  open func deactivate() {

  }
}