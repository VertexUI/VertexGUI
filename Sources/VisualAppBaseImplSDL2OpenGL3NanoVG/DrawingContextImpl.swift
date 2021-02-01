import VisualAppBase
import GfxMath
import CnanovgGL3

open class SDL2OpenGL3NanoVGDrawingContext: DrawingContext {
  private let nvg: UnsafeMutablePointer<NVGcontext>

  public init(nvg: UnsafeMutablePointer<NVGcontext>) {
    self.nvg = nvg
  }

  override open func _drawRect(rect: DRect, paint: Paint) {
    print("CALLED DRAW RECT")
  }
}