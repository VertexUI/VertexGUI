extension Experimental {
  public struct Style {
    public var selector: StyleSelector
    public var properties: [StyleProperty]
    public var children: [Style]
    
    init(_ selector: StyleSelector, @StyleBuilder content contentBuilder: () -> StyleBuilder.IntermediateResult) {
      self.selector = selector
      let content = contentBuilder()
      self.properties = content.properties
      self.children = content.children
    }

    init(selector: StyleSelector, properties: [StyleProperty], children: [Style]) {
      self.selector = selector
      self.properties = properties
      self.children = children
    }
  }
}