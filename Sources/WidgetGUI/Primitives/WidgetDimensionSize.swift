public enum WidgetDimensionSize: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
  public init(floatLiteral: Double) {
    self = .a(floatLiteral)
  }

  public init(integerLiteral: Int) {
    self = .a(Double(integerLiteral))
  }

  /// absolute value (in pixels)
  case a(Double)
  /// percent of root width
  case rw(Double)
  /// percent of root height
  case rh(Double)
}