import SkiaKit
import GfxMath

extension Canvas {
  public func drawLine(_ start: DVec2, _ end: DVec2, paint: Paint) {
    drawLine(x0: Float(start.x), y0: Float(start.y), x1: Float(end.x), y1: Float(end.y), paint: paint)
  }

  public func drawRect(_ rect: DRect, _ paint: Paint) {
    drawRect(SkiaKit.Rect(x: Float(rect.min.x), y: Float(rect.min.y), width: Float(rect.size.width), height: Float(rect.size.height)), paint)
  }
}