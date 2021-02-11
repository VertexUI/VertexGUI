import GfxMath

open class Layout {
  open var parentPropertySupportDefinitions: Experimental.StylePropertySupportDefinitions {
    fatalError("parentPropertySupportDefinitions not implemented")
  }
  open var childPropertySupportDefinitions: Experimental.StylePropertySupportDefinitions {
    fatalError("childPropertySupportDefinitions not implemented")
  }
  public internal(set) var widgets: [Widget] = []

  required public init(widgets: [Widget]) {
    self.widgets = widgets
  }

  open func getBoxConfig() -> BoxConfig {
    fatalError("getBoxConfig() not implemented")
  }

  open func layout(constraints: BoxConstraints) -> DSize2 {
    fatalError("layout() not implemented")
  }
}