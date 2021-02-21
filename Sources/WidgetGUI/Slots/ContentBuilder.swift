@_functionBuilder
public struct ExpDirectContentBuilder {
  public static func buildExpression(_ widget: Widget) -> [ExpDirectContent.Partial] {
    [.widget(widget)]
  }

  public static func buildExpression(_ content: ExpDirectContent) -> [ExpDirectContent.Partial] {
    [.content(content)]
  }

  public static func buildExpression(_ dynamic: Dynamic<ExpDirectContent>) -> [ExpDirectContent.Partial] {
    [.content(dynamic.content)]
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
  public static func buildExpression(_ slotContentDefinition: AnySlotContentManagerDefinition) -> [ExpSlottingContent.Partial] {
    [.slotContentDefinition(slotContentDefinition)]
  }

  public static func buildExpression<D>(_ slotContentDefinition: SlotContentDefinition<D>) -> [ExpSlottingContent.Partial] {
    [.slotContentDefinition(slotContentDefinition)]
  }

  public static func buildExpression(_ dynamic: Dynamic<ExpSlottingContent>) -> [ExpSlottingContent.Partial] {
    [.slottingContent(dynamic.content)]
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