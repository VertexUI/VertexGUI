import VisualAppBase

public class Style {
  public var selector: StyleSelector
  public var properties: StyleProperties
  public var children: [Style]
  public var sourceScope: UInt
  public var treePath: TreePath? = nil
  public private(set) var parent: Style?
  
  public init(_ selector: StyleSelector, _ properties: StyleProperties, _ children: [Style]) {
    self.selector = selector
    self.properties = properties
    self.children = children
    self.sourceScope = Widget.activeStyleScope
    applyAsParent()
  }

  public convenience init(selector: StyleSelector, properties: StyleProperties, children: [Style]) {
    self.init(selector, properties, children)
  }

  public convenience init(_ selector: StyleSelector, @StyleBuilder content contentBuilder: () -> StyleBuilder.IntermediateResult) {
    let content = contentBuilder()
    self.init(selector, StyleProperties(content.properties), content.children)
  }

  public convenience init(_ selector: StyleSelector, @StyleBuilder content contentBuilder: (AnyDefaultStyleKeys.Type) -> StyleBuilder.IntermediateResult) {
    let content = contentBuilder(AnyDefaultStyleKeys.self)
    self.init(selector, StyleProperties(content.properties), content.children)
  }

  public convenience init<W: StylableWidget>(
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