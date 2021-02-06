extension Experimental {
  public class Style {
    public var selector: StyleSelector
    public var properties: StyleProperties
    public var children: [Style]
    public var sourceScope: UInt
    public private(set) var parent: Experimental.Style?
    
    public init(_ selector: StyleSelector, _ properties: StyleProperties, _ children: [Experimental.Style]) {
      self.selector = selector
      self.properties = properties
      self.children = children
      self.sourceScope = Widget.activeStyleScope
      applyAsParent()
    }

    public convenience init(selector: StyleSelector, properties: Experimental.StyleProperties, children: [Style]) {
      self.init(selector, properties, children)
    }

    public convenience init(_ selector: StyleSelector, @StyleBuilder content contentBuilder: () -> StyleBuilder.IntermediateResult) {
      let content = contentBuilder()
      self.init(selector, StyleProperties(content.properties), content.children)
    }

    public convenience init(_ selector: StyleSelector, @StyleBuilder content contentBuilder: (Experimental.AnyDefaultStyleKeys.Type) -> StyleBuilder.IntermediateResult) {
      let content = contentBuilder(Experimental.AnyDefaultStyleKeys.self)
      self.init(selector, StyleProperties(content.properties), content.children)
    }

    public convenience init<W: ExperimentalStylableWidget>(
      _ selector: StyleSelector,
      _ widget: W.Type,
      @StyleBuilder content contentBuilder: (W.StyleKeys.Type) -> StyleBuilder.IntermediateResult) {
        let content = contentBuilder(W.StyleKeys.self)
        self.init(selector, StyleProperties(content.properties), content.children)
    }

    private func applyAsParent() {
      for child in children {
        child.parent = self
      }
    }
  }
}