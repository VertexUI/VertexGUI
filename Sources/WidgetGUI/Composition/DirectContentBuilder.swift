@resultBuilder
public struct DirectContentBuilder {
  public static func buildExpression(_ widget: Widget) -> [DirectContent.Partial] {
    [.widget(widget)]
  }

  public static func buildExpression(_ widgets: [Widget]) -> [DirectContent.Partial] {
    widgets.map { .widget($0) }
  }

  public static func buildExpression(_ content: DirectContent) -> [DirectContent.Partial] {
    [.content(content)]
  }

  public static func buildExpression(_ dynamicContent: Dynamic<DirectContent>) -> [DirectContent.Partial] {
    [.dynamic(dynamicContent)]
  }

  public static func buildOptional(_ partials: [DirectContent.Partial]?) -> [DirectContent.Partial] {
    partials ?? []
  }

  public static func buildEither(first: [DirectContent.Partial]) -> [DirectContent.Partial] {
    return first
  }

  public static func buildEither(second: [DirectContent.Partial]) -> [DirectContent.Partial] {
    return second
  }

  public static func buildArray(_ components: [[DirectContent.Partial]]) -> [DirectContent.Partial] {
    components.flatMap { $0 }
  }

  public static func buildBlock(_ partials: [DirectContent.Partial]...) -> [DirectContent.Partial] {
    partials.flatMap { $0 }
  }

  public static func buildFinalResult(_ partials: [DirectContent.Partial]) -> [DirectContent.Partial] {
    partials
  }

  public static func buildFinalResult(_ partials: [DirectContent.Partial]) -> DirectContent {
    DirectContent(partials: partials)
  }
}