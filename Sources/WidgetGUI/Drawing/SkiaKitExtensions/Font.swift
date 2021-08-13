import SkiaKit
import GfxMath

extension SkiaKit.Font {
  public func measureText(_ text: String, paint: Paint) -> DRect {
    measureText(text, paint: paint).asDRect()
  }
}