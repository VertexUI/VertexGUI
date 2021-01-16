extension Widget {
  @_functionBuilder
  public struct MultiChildContentBuilder {
    public static func buildExpression(_ widgetBuildFunction: @autoclosure @escaping () -> Widget) -> IntermediateResult {
      IntermediateResult(childrenBuildFunctions: [{ [widgetBuildFunction()] }])
    }

    public static func buildExpression(_ widgetBuildFunction: @autoclosure @escaping () -> [Widget]) -> IntermediateResult {
      IntermediateResult(childrenBuildFunctions: [widgetBuildFunction])
    }

    public static func buildExpression(_ style: Experimental.Style) -> IntermediateResult {
      IntermediateResult(experimentalStyles: [style])
    }

    public static func buildEither(first: IntermediateResult) -> IntermediateResult {
      first
    }

    public static func buildEither(second: IntermediateResult) -> IntermediateResult {
      second
    }

    public static func buildBlock(_ results: IntermediateResult...) -> IntermediateResult {
      buildBlock(results)
    }

    public static func buildBlock(_ results: [IntermediateResult]) -> IntermediateResult {
      results.reduce(into: IntermediateResult()) {
        $0.childrenBuildFunctions.append(contentsOf: $1.childrenBuildFunctions)
        $0.experimentalStyles.append(contentsOf: $1.experimentalStyles)
      }
    }

    public static func buildFinalResult(_ intermediate: IntermediateResult) -> Result {
      Result(
        childrenBuilder: ChildrenBuilder(
          buildFunctions: intermediate.childrenBuildFunctions, 
          associatedStyleScope: Widget.activeStyleScope),
        experimentalStyles: intermediate.experimentalStyles)
    }

    public struct IntermediateResult {
      public var childrenBuildFunctions: [() -> [Widget]] = []
      public var experimentalStyles: [Experimental.Style] = []
    }

    public struct Result {
      public var childrenBuilder: ChildrenBuilder
      public var experimentalStyles: [Experimental.Style]
    }

    public struct ChildrenBuilder {
      public let buildFunctions: [() -> [Widget]]
      public let associatedStyleScope: UInt?

      public func callAsFunction() -> [Widget] {
        Widget.inStyleScope(associatedStyleScope) {
          buildFunctions.map { $0() }
        }.flatMap { $0 }
      }
    }
  }
}