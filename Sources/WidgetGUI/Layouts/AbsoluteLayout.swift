import GfxMath

public class AbsoluteLayout: Layout {
  override public var parentPropertySupportDefinitions: StylePropertySupportDefinitions {
    []
  }

  override public var childPropertySupportDefinitions: StylePropertySupportDefinitions {
    []
  }

  override public func getBoxConfig() -> BoxConfig {
    var maxBoxConfig = BoxConfig(preferredSize: .zero, minSize: .zero, maxSize: .zero)
    for widget in widgets {
      if widget.boxConfig.preferredSize.width > maxBoxConfig.preferredSize.width {
        maxBoxConfig.preferredSize.width = widget.boxConfig.preferredSize.width
      }
      if widget.boxConfig.preferredSize.height > maxBoxConfig.preferredSize.height {
        maxBoxConfig.preferredSize.height = widget.boxConfig.preferredSize.height
      }
      if widget.boxConfig.minSize.width > maxBoxConfig.minSize.width {
        maxBoxConfig.minSize.width = widget.boxConfig.minSize.width
      }
      if widget.boxConfig.minSize.height > maxBoxConfig.minSize.height {
        maxBoxConfig.minSize.height = widget.boxConfig.minSize.height
      }
      if widget.boxConfig.maxSize.width > maxBoxConfig.maxSize.width {
        maxBoxConfig.maxSize.width = widget.boxConfig.maxSize.width
      }
      if widget.boxConfig.maxSize.height > maxBoxConfig.maxSize.height {
        maxBoxConfig.maxSize.height = widget.boxConfig.maxSize.height
      }
    }
    return maxBoxConfig
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