import SkiaKit
import GfxMath

extension Paint {
  public convenience init(color: GfxMath.Color, style: Paint.Style, isAntialias: Bool) {
    self.init()
    self.color = Color(color)
    self.style = style
    self.isAntialias = isAntialias
  }
}