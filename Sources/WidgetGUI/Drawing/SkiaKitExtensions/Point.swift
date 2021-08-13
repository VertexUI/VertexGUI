import SkiaKit
import GfxMath

extension SkiaKit.Point {
  public func asDVec2() -> DVec2 {
    DVec2(Double(x), Double(y))
  }

  public init(_ point: FVec2) {
    self.init(x: point.x, y: point.y)
  }
}