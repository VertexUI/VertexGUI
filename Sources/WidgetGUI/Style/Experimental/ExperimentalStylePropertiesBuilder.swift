extension Experimental {
  @_functionBuilder
  public struct StylePropertiesBuilder {
    public static func buildExpression(_ expression: Experimental.StyleProperty.SpecificInitTuple) -> Experimental.StyleProperty {
      Experimental.StyleProperty(key: expression.0, value: expression.1)
    }
    
    public static func buildBlock(_ properties: Experimental.StyleProperty...) -> [Experimental.StyleProperty] {
      properties
    }
  }
}