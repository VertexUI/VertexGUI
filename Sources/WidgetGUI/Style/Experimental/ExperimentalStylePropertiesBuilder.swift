import ExperimentalReactiveProperties

extension Experimental {
  @_functionBuilder
  public struct StylePropertiesBuilder {
    public static func buildExpression(_ expression: (StyleKey, StyleValue)) -> Experimental.StyleProperty {
      Experimental.StyleProperty(key: expression.0, value: expression.1)
    }
    
    public static func buildExpression<P: ReactiveProperty>(_ expression: (StyleKey, P)) -> Experimental.StyleProperty where P.Value: StyleValue {
      Experimental.StyleProperty(key: expression.0, value: expression.1)
    }
    
    public static func buildBlock(_ properties: Experimental.StyleProperty...) -> [Experimental.StyleProperty] {
      properties
    }

    public static func buildFinalResult(_ properties: [Experimental.StyleProperty]) -> Experimental.StyleProperties {
      Experimental.StyleProperties(properties)
    }
  }
}