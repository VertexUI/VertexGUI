extension Widget { 
  /**
  TODO: might rename to something like SingleChildContentBuilder / SingleChildContentBuilder ...
  because it can build styles as well
  */
  @_functionBuilder
  public struct SingleChildContentBuilder {
    private static func mergeIntermediates(_ intermediates: [IntermediateResult]) -> IntermediateResult {
      var resultChild: (() -> Widget)?
      var styles: [Style] = []
      for intermediate in intermediates {
        if intermediate.child != nil && resultChild == nil {
          resultChild = intermediate.child
        } else if intermediate.child != nil && resultChild != nil {
          fatalError("provided multiple children inside a parent which accepts only one child")
        }
        styles.append(contentsOf: intermediate.styles)
      }
      return IntermediateResult(child: resultChild, styles: styles)
    }

    public static func buildExpression(_ widget: @autoclosure @escaping () -> Widget) -> IntermediateResult {
      IntermediateResult(child: widget)
    }

    public static func buildExpression(_ style: Style) -> IntermediateResult {
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
      guard let unwrappedChildBuildFunction = intermediate.child else {
        fatalError("did not provide a child for a parent which expects exactly one child")
      }

      let childBuilder = ChildBuilder(associatedStyleScope: Widget.activeStyleScope,
        build: unwrappedChildBuildFunction)

      return Result(child: childBuilder, styles: intermediate.styles)
    }

    public struct IntermediateResult {
      var child: (() -> Widget)?
      var styles: [Style]

      init(child: (() -> Widget)? = nil, styles: [Style] = []) {
        self.child = child
        self.styles = styles
      }
    }

    public struct Result {
      public var child: ChildBuilder
      public var styles: [Style]
    }

    public struct ChildBuilder {
      private let associatedStyleScope: UInt
      private let build: () -> Widget

      public init(associatedStyleScope: UInt, build: @escaping () -> Widget) {
        self.associatedStyleScope = associatedStyleScope
        self.build = build
      }

      public func callAsFunction() -> Widget {
        Widget.inStyleScope(associatedStyleScope, block: build)
      }
    }
  }
}