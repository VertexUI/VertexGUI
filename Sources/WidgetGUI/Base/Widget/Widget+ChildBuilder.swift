extension Widget {
  @_functionBuilder
  public struct ChildBuilder {
    private static func mergeIntermediates(_ intermediates: [IntermediateResult]) -> IntermediateResult {
      var resultChild: Widget?
      var resultStyles: [AnyStyle] = []
      for intermediate in intermediates {
        if intermediate.child != nil && resultChild == nil {
          resultChild = intermediate.child
        } else if intermediate.child != nil && resultChild != nil {
          fatalError("provided multiple children inside a parent which accepts only one child")
        }
        resultStyles.append(contentsOf: intermediate.styles)
      }
      return IntermediateResult(child: resultChild, styles: resultStyles)
    }

    public static func buildExpression(_ widget: Widget) -> IntermediateResult {
      IntermediateResult(child: widget)
    }

    public static func buildExpression(_ style: AnyStyle) -> IntermediateResult {
      IntermediateResult(styles: [style])
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

      return Result(child: unwrappedChild, styles: intermediate.styles)
    }

    public struct IntermediateResult {
      var child: Widget?
      var styles: [AnyStyle] 

      init(child: Widget? = nil, styles: [AnyStyle] = []) {
        self.child = child
        self.styles = styles
      }
    }

    public struct Result {
      public var child: Widget
      public var styles: [AnyStyle]
    }
  }
}