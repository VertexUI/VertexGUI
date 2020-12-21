extension Widget {
  @_functionBuilder
  public struct ChildrenBuilder {
    public static func buildExpression(_ style: AnyStyle?) -> Result {
      Result(styles: style != nil ? [style!] : [])
    }

    public static func buildExpression(_ widget: Widget?) -> Result {
      Result(children: widget != nil ? [widget!] : [])
    }

    public static func buildEither(first: Result) -> Result {
      first
    }

    public static func buildEither(second: Result) -> Result {
      second
    }

    public static func buildBlock(_ results: Result...) -> Result {
      buildBlock(results)
    }

    public static func buildBlock(_ results: [Result]) -> Result {
      results.reduce(into: Result()) {
        $0.children.append(contentsOf: $1.children)
        $0.styles.append(contentsOf: $1.styles)
      }
    }

    public struct Result {
      public var children: [Widget] = []
      public var styles: [AnyStyle] = []
    }
  }
}