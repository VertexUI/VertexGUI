import GfxMath

public class AbsoluteLayout: Layout {
  override public var parentPropertySupportDefinitions: Experimental.StylePropertySupportDefinitions {
    []
  }

  override public var childPropertySupportDefinitions: Experimental.StylePropertySupportDefinitions {
    []
  }

  override public func getBoxConfig() -> BoxConfig {
    widgets[0].boxConfig
  }

  override public func layout(constraints: BoxConstraints) -> DSize2 {
    var maxSize = DSize2.zero
    for widget in widgets {
      widget.layout(constraints: constraints)
      if widget.width > maxSize.width {
        maxSize.width = widget.width
      }
      if widget.height > maxSize.height {
        maxSize.height = widget.height
      }
    }
    return maxSize
  }
}