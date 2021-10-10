import SkiaKit
import GfxMath

extension Paint {
  public convenience init(color: GfxMath.Color, style: Paint.Style, isAntialias: Bool = true) {
    self.init()
    self.color = Color(color)
    self.style = style
    self.isAntialias = isAntialias
  }

  public static func fill(color: GfxMath.Color) -> Paint {
    var paint = Paint()
    paint.style = .fill
    paint.color = Color(color)
    paint.isAntialias = true
    return paint
  }

  public static func stroke(color: GfxMath.Color, width: Double) -> Paint {
    var paint = Paint()
    paint.style = .stroke
    paint.color = Color(color)
    paint.strokeWidth = Float(width)
    return paint
  }
}