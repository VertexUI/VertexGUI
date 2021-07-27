import SkiaKit
import GfxMath

extension SkiaKit.Rect {
  public func asDRect() -> DRect {
    DRect(center: DVec2(Double(midX), Double(midY)), size: DSize2(Double(width), Double(height)))
  }

  public init(_ rect: FRect) {
    self.init(x: rect.min.x, y: rect.min.y, width: rect.size.width, height: rect.size.height)
  }
}