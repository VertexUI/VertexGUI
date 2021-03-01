import GfxMath

open class Layout {
  unowned public internal(set) var container: Container
  public internal(set) var widgets: [Widget] {
    didSet {
      setupChildrenPropertyChangeHandlers()
    }
  }

  required public init(container: Container, widgets: [Widget]) {
    self.container = container
    self.widgets = widgets

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