extension Experimental {
  public class Style {
    public var selector: StyleSelector
    public var properties: StyleProperties
    public var children: [Style]
    
    public init(_ selector: StyleSelector, @StyleBuilder content contentBuilder: () -> StyleBuilder.IntermediateResult) {
      self.selector = selector
      let content = contentBuilder()
      self.properties = StyleProperties(content.properties)
      self.children = content.children
    }

    public init(selector: StyleSelector, properties: Experimental.StyleProperties, children: [Style]) {
      self.selector = selector
      self.properties = properties
      self.children = children
    }
  }
}