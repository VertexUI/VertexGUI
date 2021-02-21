@_functionBuilder
public struct ExpDirectContentBuilder {
  public static func buildExpression(_ widget: Widget) -> [ExpDirectContent.Partial] {
    [.widget(widget)]
  }

  public static func buildExpression(_ widgets: [Widget]) -> [ExpDirectContent.Partial] {
    widgets.map { .widget($0) }
  }

  public static func buildExpression(_ content: ExpDirectContent) -> [ExpDirectContent.Partial] {
    [.content(content)]
  }

  public static func buildExpression(_ dynamic: Dynamic<ExpDirectContent>) -> [ExpDirectContent.Partial] {
    [.content(dynamic.content)]
  }

  public static func buildOptional(_ partials: [ExpDirectContent.Partial]?) -> [ExpDirectContent.Partial] {
    partials ?? []
  }

  public static func buildEither(first: [ExpDirectContent.Partial]) -> [ExpDirectContent.Partial] {
    return first
  }

  public static func buildEither(second: [ExpDirectContent.Partial]) -> [ExpDirectContent.Partial] {
    return second
  }

  public static func buildBlock(_ partials: [ExpDirectContent.Partial]...) -> [ExpDirectContent.Partial] {
    partials.flatMap { $0 }
  }

  public static func buildFinalResult(_ partials: [ExpDirectContent.Partial]) -> [ExpDirectContent.Partial] {
    partials
  }

  public static func buildFinalResult(_ partials: [ExpDirectContent.Partial]) -> ExpDirectContent {
    ExpDirectContent(partials: partials)
  }
}

@_functionBuilder
public struct ExpSlottingContentBuilder {
  public static func buildExpression(_ widget: Widget) -> [ExpSlottingContent.Partial] {
    [.widget(widget)]
  }

  public static func buildExpression(_ widgets: [Widget]) -> [ExpSlottingContent.Partial] {
    widgets.map { .widget($0) }
  }

  public static func buildExpression(_ directContent: ExpDirectContent) -> [ExpSlottingContent.Partial] {
    [.directContent(directContent)]
  }

  public static func buildExpression(_ slotContentDefinition: AnySlotContentDefinition) -> [ExpSlottingContent.Partial] {
    [.slotContentDefinition(slotContentDefinition)]
  }

  public static func buildOptional(_ partials: [ExpSlottingContent.Partial]?) -> [ExpSlottingContent.Partial] {
    partials ?? []
  }

  public static func buildExpression(_ dynamic: Dynamic<ExpSlottingContent>) -> [ExpSlottingContent.Partial] {
    [.slottingContent(dynamic.content)]
  }

  public static func buildEither(first: [ExpSlottingContent.Partial]) -> [ExpSlottingContent.Partial] {
    return first
  }

  public static func buildEither(second: [ExpSlottingContent.Partial]) -> [ExpSlottingContent.Partial] {
    return second
  }

  public static func buildBlock(_ partials: [ExpSlottingContent.Partial]...) -> [ExpSlottingContent.Partial] {
    partials.flatMap { $0 }
  }

  public static func buildFinalResult(_ partials: [ExpSlottingContent.Partial]) -> [ExpSlottingContent.Partial] {
    partials
  }

  public static func buildFinalResult(_ partials: [ExpSlottingContent.Partial]) -> ExpSlottingContent {
    ExpSlottingContent(partials: partials)
  }
}