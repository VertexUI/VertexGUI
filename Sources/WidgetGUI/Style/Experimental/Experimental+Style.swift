extension Experimental {
  public class Style {
    let selector: StyleSelector
    let propertyValueDefinitions: [StylePropertyValueDefinition]
    let children: [Style]
    let sourceScope: UInt

    public init<W: Widget>(
      _ selector: StyleSelector,
      _ widgetType: W.Type,
      @StylePropertyValueDefinitionsBuilder<W> properties buildDefinitions: () ->
        [StylePropertyValueDefinition],
      @NestedStylesBuilder nested buildNestedStyles: () -> [Experimental.Style] = { [] }
    ) {
      self.selector = selector
      self.propertyValueDefinitions = buildDefinitions()
      self.children = buildNestedStyles()
      self.sourceScope = Widget.activeStyleScope
    }

    public convenience init(_ selector: StyleSelector,
      @StylePropertyValueDefinitionsBuilder<Widget> properties buildDefinitions: () ->
        [StylePropertyValueDefinition],
      @NestedStylesBuilder nested buildNestedStyles: () -> [Experimental.Style] = { [] }
    ) {
      self.init(selector, Widget.self, properties: buildDefinitions, nested: buildNestedStyles)
    }
  }
}

extension Experimental.Style {
  @_functionBuilder
  public struct NestedStylesBuilder {
    public static func buildExpression(_ style: Experimental.Style) -> [Experimental.Style] {
      [style]
    }

    public static func buildBlock(_ partials: [[Experimental.Style]]) -> [Experimental.Style] {
      partials.flatMap { $0 }
    }

    public static func buildBlock(_ partials: [Experimental.Style]...) -> [Experimental.Style] {
      buildBlock(partials)
    }
  }
}
