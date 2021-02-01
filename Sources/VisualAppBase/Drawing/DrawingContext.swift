import GfxMath

open class DrawingContext {
  public let surface: DrawingSurface
  public let inherentOpacity: Double
  public let inherentTransforms: [Transform]

  public init(surface: DrawingSurface, opacity: Double = 1, transforms: [Transform] = []) {
    self.surface = surface
    self.inherentOpacity = opacity
    self.inherentTransforms = transforms
  }

  public func derive(opacity: Double = 1) -> DrawingContext {
    if opacity > 1 {
      fatalError("opacity must be <= than 1")
    }
    return DrawingContext(surface: surface, opacity: self.inherentOpacity * opacity)
  }

  open func beginDrawing() {

  }

  public func drawRect(rect: DRect, paint: Paint) {
    _drawRect(rect: rect, paint: paint)
  }

  /** For internal use. Called by drawRect() with all transforms etc. applied. */
  open func _drawRect(rect: DRect, paint: Paint) {
    fatalError("drawRect() not implemented")
  }

  open func drawRoundedRect() {

  }

  open func drawPath() {
    
  }

  open func endDrawing() {

  }

  public struct Transform {}
}