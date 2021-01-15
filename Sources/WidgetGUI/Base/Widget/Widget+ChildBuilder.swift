extension Widget { 
  /**
  TODO: might rename to something like ContentBuilder / SingleChildContentBuilder ...
  because it can build styles as well
  */
  @_functionBuilder
  public struct ChildBuilder {
    private static func mergeIntermediates(_ intermediates: [IntermediateResult]) -> IntermediateResult {
      var resultChild: (() -> Widget)?
      var resultStyles: [AnyStyle] = []
      var experimentalStyles: [Experimental.Style] = []
      for intermediate in intermediates {
        if intermediate.child != nil && resultChild == nil {
          resultChild = intermediate.child
        } else if intermediate.child != nil && resultChild != nil {
          fatalError("provided multiple children inside a parent which accepts only one child")
        }
        resultStyles.append(contentsOf: intermediate.styles)
        experimentalStyles.append(contentsOf: intermediate.experimentalStyles)
      }
      return IntermediateResult(child: resultChild, styles: resultStyles, experimentalStyles: experimentalStyles)
    }

    public static func buildExpression(_ widget: @autoclosure @escaping () -> Widget) -> IntermediateResult {
      IntermediateResult(child: widget)
    }

    public static func buildExpression(_ style: AnyStyle) -> IntermediateResult {
      IntermediateResult(styles: [style])
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

    public static func buildBlock(_ intermediates: IntermediateResult...) -> IntermediateResult {
      mergeIntermediates(intermediates)
    }

    public static func buildFinalResult(_ intermediate: IntermediateResult) -> Result {
      guard let unwrappedChild = intermediate.child else {
        fatalError("did not provide a child for a parent which expects exactly one child")
      }

      return Result(child: unwrappedChild, styles: intermediate.styles, experimentalStyles: intermediate.experimentalStyles)
    }

    public struct IntermediateResult {
      var child: (() -> Widget)?
      var styles: [AnyStyle] 
      var experimentalStyles: [Experimental.Style]

      init(child: (() -> Widget)? = nil, styles: [AnyStyle] = [], experimentalStyles: [Experimental.Style] = []) {
        self.child = child
        self.styles = styles
        self.experimentalStyles = experimentalStyles
      }
    }

    public struct Result {
      public var child: () -> Widget
      public var styles: [AnyStyle]
      public var experimentalStyles: [Experimental.Style]
    }
  }
}