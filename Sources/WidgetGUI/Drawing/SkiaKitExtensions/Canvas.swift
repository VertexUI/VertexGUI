import SkiaKit
import GfxMath

extension Canvas {
  public func drawRect(_ rect: DRect, _ paint: Paint) {
    drawRect(SkiaKit.Rect(x: Float(rect.min.x), y: Float(rect.min.y), width: Float(rect.size.width), height: Float(rect.size.height)), paint)
  }
}