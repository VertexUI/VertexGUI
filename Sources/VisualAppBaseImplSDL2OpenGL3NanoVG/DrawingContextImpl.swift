import VisualAppBase
import GfxMath
import CnanovgGL3

open class SDL2OpenGL3NanoVGDrawingContext: DrawingContext {
  private let nvg: UnsafeMutablePointer<NVGcontext>

  public init(surface: DrawingSurface, nvg: UnsafeMutablePointer<NVGcontext>) {
    self.nvg = nvg
    super.init(surface: surface)
  }

  override public func beginDrawing() {
    nvgBeginFrame(nvg, Float(surface.size.width), Float(surface.size.height), Float(surface.resolution))
  }

  override open func _drawRect(rect: DRect, paint: Paint) {
    if let color = paint.color {
      nvgFillColor(nvg, color.toNVG())
    }
    nvgRect(
      nvg,
      Float(rect.min.x),
      Float(rect.min.y),
      Float(rect.size.width),
      Float(rect.size.height))
    nvgFill(nvg)
  }

  override public func endDrawing() {
    nvgEndFrame(nvg)
  }
}