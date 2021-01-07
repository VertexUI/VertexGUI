extension Experimental.Style {
  @_functionBuilder
  public struct StyleBuilder {
    public typealias PropertyTuple = (StyleKey, StyleValue)

    public struct IntermediateResult {
      public var properties: [Experimental.StyleProperty]
      public var children: [Experimental.Style]

      public init(properties: [Experimental.StyleProperty] = [], children: [Experimental.Style] = []) {
        self.properties = properties
        self.children = children
      }
    }

    public static func buildExpression(_ expression: PropertyTuple) -> IntermediateResult {
      IntermediateResult(properties: [Experimental.StyleProperty(key: expression.0, value: expression.1)])
    } 

    public static func buildExpression(_ expression: Experimental.Style) -> IntermediateResult {
      IntermediateResult(children: [expression])
    }

    public static func buildBlock(_ intermediates: IntermediateResult...) -> IntermediateResult {
      var merged = IntermediateResult()
      for intermediate in intermediates {
        merged.properties.append(contentsOf: intermediate.properties)
        merged.children.append(contentsOf: intermediate.children)
      }
      return merged
    }
  }
}