import GfxMath

public struct TextPaint {
  public var color: Color? = nil
  public var breakWidth: Double? = nil

  public init(color: Color? = nil, breakWidth: Double? = nil) {
    self.color = color
    self.breakWidth = breakWidth
  }
}