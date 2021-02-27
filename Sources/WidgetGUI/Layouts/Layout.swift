import GfxMath

open class Layout {
  /** layout properties that are set on the parent widget */
  open var parentPropertySupportDefinitions: StylePropertySupportDefinitions {
    fatalError("parentPropertySupportDefinitions not implemented")
  }
  /** layout properties that are set per child */
  open var childPropertySupportDefinitions: StylePropertySupportDefinitions {
    fatalError("childPropertySupportDefinitions not implemented")
  }
  unowned public internal(set) var container: Container
  public internal(set) var widgets: [Widget] {
    didSet {
      setupChildrenPropertyChangeHandlers()
    }
  }
  /** layout properties that apply to the layout as a whole (are set on the parent),
  supported properties defined in parentPropertySupportDefinitions */
  public var layoutPropertyValues: [String: Any]

  required public init(container: Container, widgets: [Widget], layoutPropertyValues: [String: Any]) {
    self.container = container
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

    setupChildrenPropertyChangeHandlers()
  }

  open func setupChildrenPropertyChangeHandlers() {

  }

  open func layout(constraints: BoxConstraints) -> DSize2 {
    fatalError("layout() not implemented")
  }
}