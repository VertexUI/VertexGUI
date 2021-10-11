@resultBuilder
public struct SlotContentBuilder {
  public typealias Component = [SlotContent.Partial]

  public static func buildExpression(_ widget: Widget) -> [SlotContent.Partial] {
    [.widget(widget)]
  }

  public static func buildExpression(_ widgets: [Widget]) -> [SlotContent.Partial] {
    widgets.map { .widget($0) }
  }

  public static func buildExpression(_ directContent: DirectContent) -> [SlotContent.Partial] {
    [.directContent(directContent)]
  }

  public static func buildExpression(_ slotContentDefinition: AnySlotContentDefinition) -> [SlotContent.Partial] {
    [.slotContentDefinition(slotContentDefinition)]
  }

  public static func buildOptional(_ partials: [SlotContent.Partial]?) -> [SlotContent.Partial] {
    partials ?? []
  }

  public static func buildExpression(_ dynamicContent: Dynamic<SlotContent>) -> [SlotContent.Partial] {
    [.dynamic(dynamicContent)]
  }

  public static func buildEither(first: [SlotContent.Partial]) -> [SlotContent.Partial] {
    return first
  }

  public static func buildEither(second: [SlotContent.Partial]) -> [SlotContent.Partial] {
    return second
  }

  public static func buildArray(_ components: [[SlotContent.Partial]]) -> [SlotContent.Partial] {
    components.flatMap { $0 }
  }

  public static func buildBlock(_ partials: [SlotContent.Partial]...) -> [SlotContent.Partial] {
    partials.flatMap { $0 }
  }

  public static func buildFinalResult(_ partials: [SlotContent.Partial]) -> [SlotContent.Partial] {
    partials
  }

  public static func buildFinalResult(_ partials: [SlotContent.Partial]) -> SlotContent {
    SlotContent(partials: partials)
  }
}