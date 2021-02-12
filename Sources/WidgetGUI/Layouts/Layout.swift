import GfxMath

open class Layout {
  /** layout properties that are set on the parent widget */
  open var parentPropertySupportDefinitions: Experimental.StylePropertySupportDefinitions {
    fatalError("parentPropertySupportDefinitions not implemented")
  }
  /** layout properties that are set per child */
  open var childPropertySupportDefinitions: Experimental.StylePropertySupportDefinitions {
    fatalError("childPropertySupportDefinitions not implemented")
  }
  public internal(set) var widgets: [Widget]
  /** layout properties that apply to the layout as a whole (are set on the parent),
  supported properties defined in parentPropertySupportDefinitions */
  public var layoutPropertyValues: [String: Any]

  required public init(widgets: [Widget], layoutPropertyValues: [String: Any]) {
    self.widgets = widgets
    self.layoutPropertyValues = layoutPropertyValues

    let mirror = Mirror(reflecting: self)
    for child in mirror.allChildren {
      if child.label == "widgets" {
        continue
      }
      if let layoutProperty = child.value as? AnyLayoutProperty {
        layoutProperty.layoutInstance = self
      }
    }
  }

  open func getBoxConfig() -> BoxConfig {
    fatalError("getBoxConfig() not implemented")
  }

  open func layout(constraints: BoxConstraints) -> DSize2 {
    fatalError("layout() not implemented")
  }
}