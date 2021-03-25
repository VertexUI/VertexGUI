import GfxMath

public struct Paint {
  public var color: Color?
  public var strokeWidth: Double?
  public var strokeColor: Color?

  public init(color: Color? = nil, strokeWidth: Double? = nil, strokeColor: Color? = nil) {
    self.color = color
    self.strokeWidth = strokeWidth
    self.strokeColor = strokeColor
  }
}