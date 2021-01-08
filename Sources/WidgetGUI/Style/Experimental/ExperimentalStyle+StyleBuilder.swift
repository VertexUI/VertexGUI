import ExperimentalReactiveProperties

extension Experimental.Style {
  @_functionBuilder
  public struct StyleBuilder {
    public struct IntermediateResult {
      public var properties: [Experimental.StyleProperty]
      public var children: [Experimental.Style]

      public init(properties: [Experimental.StyleProperty] = [], children: [Experimental.Style] = []) {
        self.properties = properties
        self.children = children
      }
    }

    public static func buildExpression(_ expression: (StyleKey, StyleValue)) -> IntermediateResult {
      IntermediateResult(properties: [Experimental.StyleProperty(key: expression.0, value: expression.1)])
    } 

    public static func buildExpression<P: ReactiveProperty>(_ expression: (StyleKey, P)) -> IntermediateResult where P.Value: StyleValue {
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