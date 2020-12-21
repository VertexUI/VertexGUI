@_functionBuilder
public struct StyleBuilder {
  public static func buildExpression(_ value: Void) -> AnyStyle? {
    nil
  }

  public static func buildExpression(_ value: AnyStyle) -> AnyStyle? {
    value
  }

  public static func buildBlock(_ styles: AnyStyle?...) -> [AnyStyle] {
    styles.compactMap { $0 }
  }

  public static func buildBlock(_ styles: [AnyStyle?]) -> [AnyStyle] {
    styles.compactMap { $0 }
  }
}