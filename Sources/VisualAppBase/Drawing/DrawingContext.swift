import GfxMath

open class DrawingContext {
  public let inherentOpacity: Double
  public let inherentTransforms: [Transform]

  public init(opacity: Double = 1, transforms: [Transform] = []) {
    self.inherentOpacity = opacity
    self.inherentTransforms = transforms
  }

  public func derive(opacity: Double = 1) -> DrawingContext {
    if opacity > 1 {
      fatalError("opacity must be <= than 1")
    }
    return DrawingContext(opacity: self.inherentOpacity * opacity)
  }

  public func drawRect(rect: DRect, paint: Paint) {
    _drawRect(rect: rect, paint: paint)
  }

  /** For internal use. Called by drawRect() with all transforms etc. applied. */
  open func _drawRect(rect: DRect, paint: Paint) {
    fatalError("drawRect() not implemented")
  }

  public func drawRoundedRect() {

  }

  public func drawPath() {
    
  }

  public struct Transform {}
}