import GfxMath

public struct TextPaint {
  public var color: Color? = nil
  public var fontConfig: FontConfig
  public var breakWidth: Double? = nil

  public init(fontConfig: FontConfig, color: Color? = nil, breakWidth: Double? = nil) {
    self.fontConfig = fontConfig
    self.color = color
    self.breakWidth = breakWidth
  }
}