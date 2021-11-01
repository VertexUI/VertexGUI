import SkiaKit
import GfxMath

extension Canvas {
  public func drawPoint(_ point: DVec2, paint: Paint) {
    drawPoint(Float(point.x), Float(point.y), paint)
  }

  public func drawPoint(_ point: DVec2, color: GfxMath.Color) {
    drawPoint(point, paint: Paint.fill(color: color))
  }

  public func drawLine(from start: DVec2, to end: DVec2, paint: Paint) {
    drawLine(x0: Float(start.x), y0: Float(start.y), x1: Float(end.x), y1: Float(end.y), paint: paint)
  }

  public func drawRect(_ rect: FRect, _ paint: Paint) {
    drawRect(SkiaKit.Rect(rect), paint)
  }

  public func drawRect(_ rect: DRect, _ paint: Paint) {
    drawRect(FRect(rect), paint)
  }

  public func drawCircle(center: FVec2, radius: Float, paint: Paint) {
    drawCircle(center.x, center.y, radius, paint)
  }

  public func drawCircle(center: DVec2, radius: Double, paint: Paint) {
    drawCircle(Float(center.x), Float(center.y), Float(radius), paint)
  }

  public func scale(x: Float, y: Float, pivot: FVec2) {
    scale(sx: x, sy: y, pivot: SkiaKit.Point(pivot))
  }
}