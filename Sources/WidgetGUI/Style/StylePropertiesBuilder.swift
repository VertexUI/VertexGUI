import ReactiveProperties

@_functionBuilder
public struct StylePropertiesBuilder {
  public static func buildExpression(_ expression: (StyleKey, StyleValue)) -> StyleProperty {
    StyleProperty(key: expression.0, value: expression.1)
  }
  
  public static func buildExpression<P: ReactiveProperty>(_ expression: (StyleKey, P)) -> StyleProperty where P.Value == StyleValue? {
    StyleProperty(key: expression.0, value: expression.1)
  }

  public static func buildExpression<P: ReactiveProperty>(_ expression: (StyleKey, P)) -> StyleProperty where P.Value: StyleValue {
    StyleProperty(key: expression.0, value: expression.1)
  }

  public static func buildExpression(_ expression: (StyleKey, SpecialStyleValue)) -> StyleProperty {
    StyleProperty(key: expression.0, value: expression.1)
  }
  
  public static func buildBlock(_ properties: StyleProperty...) -> [StyleProperty] {
    properties
  }

  public static func buildFinalResult(_ properties: [StyleProperty]) -> StyleProperties {
    StyleProperties(properties)
  }
}