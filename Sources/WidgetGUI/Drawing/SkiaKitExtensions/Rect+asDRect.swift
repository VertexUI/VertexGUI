import SkiaKit
import GfxMath

extension SkiaKit.Rect {
  public func asDRect() -> DRect {
    DRect(center: DVec2(Double(midX), Double(midY)), size: DSize2(Double(width), Double(height)))
  }
}