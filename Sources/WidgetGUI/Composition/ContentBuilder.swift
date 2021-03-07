@_functionBuilder
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

  public static func buildExpression(_ dynamic: Dynamic<DirectContent>) -> [DirectContent.Partial] {
    [.dynamic(dynamic)]
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

@_functionBuilder
public struct SlottingContentBuilder {
  public static func buildExpression(_ widget: Widget) -> [SlottingContent.Partial] {
    [.widget(widget)]
  }

  public static func buildExpression(_ widgets: [Widget]) -> [SlottingContent.Partial] {
    widgets.map { .widget($0) }
  }

  public static func buildExpression(_ directContent: DirectContent) -> [SlottingContent.Partial] {
    [.directContent(directContent)]
  }

  public static func buildExpression(_ slotContentDefinition: AnySlotContentDefinition) -> [SlottingContent.Partial] {
    [.slotContentDefinition(slotContentDefinition)]
  }

  public static func buildOptional(_ partials: [SlottingContent.Partial]?) -> [SlottingContent.Partial] {
    partials ?? []
  }

  public static func buildExpression(_ dynamic: Dynamic<SlottingContent>) -> [SlottingContent.Partial] {
    [.dynamic(dynamic)]
  }

  public static func buildEither(first: [SlottingContent.Partial]) -> [SlottingContent.Partial] {
    return first
  }

  public static func buildEither(second: [SlottingContent.Partial]) -> [SlottingContent.Partial] {
    return second
  }

  public static func buildBlock(_ partials: [SlottingContent.Partial]...) -> [SlottingContent.Partial] {
    partials.flatMap { $0 }
  }

  public static func buildFinalResult(_ partials: [SlottingContent.Partial]) -> [SlottingContent.Partial] {
    partials
  }

  public static func buildFinalResult(_ partials: [SlottingContent.Partial]) -> SlottingContent {
    SlottingContent(partials: partials)
  }
}