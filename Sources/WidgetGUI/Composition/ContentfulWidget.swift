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

  override public func destroySelf() {
    if let content = _content {
      content.destroy()
    }
  }
}