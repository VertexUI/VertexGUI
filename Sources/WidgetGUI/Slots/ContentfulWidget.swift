import GfxMath

open class ContentfulWidget: Widget {
  private var _content: ExpDirectContent?
  open var content: ExpDirectContent {
    fatalError("content not implemented")
  }

  final override public func performBuild() {
    _content = content 
    contentChildren = _content!.widgets
    _ = _content!.onChanged { [unowned self] in
      contentChildren = _content!.widgets
    }
  }

  override open func getContentBoxConfig() -> BoxConfig {
    var maxBoxConfig = BoxConfig(preferredSize: .zero, minSize: .zero, maxSize: .zero)
    for child in contentChildren {
      if child.boxConfig.preferredSize.width > maxBoxConfig.preferredSize.width {
        maxBoxConfig.preferredSize.width = child.boxConfig.preferredSize.width
      }
      if child.boxConfig.preferredSize.height > maxBoxConfig.preferredSize.height {
        maxBoxConfig.preferredSize.height = child.boxConfig.preferredSize.height
      }
      if child.boxConfig.minSize.width > maxBoxConfig.minSize.width {
        maxBoxConfig.minSize.width = child.boxConfig.minSize.width
      }
      if child.boxConfig.minSize.height > maxBoxConfig.minSize.height {
        maxBoxConfig.minSize.height = child.boxConfig.minSize.height
      }
      if child.boxConfig.maxSize.width > maxBoxConfig.maxSize.width {
        maxBoxConfig.maxSize.width = child.boxConfig.maxSize.width
      }
      if child.boxConfig.maxSize.height > maxBoxConfig.maxSize.height {
        maxBoxConfig.maxSize.height = child.boxConfig.maxSize.height
      }
    }
    return maxBoxConfig
  }

  override open func performLayout(constraints: BoxConstraints) -> DSize2 {
    var maxSize = DSize2.zero
    for child in contentChildren {
      child.layout(constraints: constraints)
      if child.width > maxSize.width {
        maxSize.width = child.width
      }
      if child.height > maxSize.height {
        maxSize.height = child.height
      }
    }
    return maxSize
  }
}