import GfxMath

open class ComposedWidget: Widget {
  private var _content: DirectContent?
  open var content: DirectContent {
    fatalError("content not implemented")
  }

  override public init() {
    super.init()
    _ = onDestroy { [unowned self] in
      if let content = _content {
        content.destroy()
      }
      _content = nil
    }
  }

  override public func performBuild() {
    _content = content 
    contentChildren = _content!.widgets
    _ = onDestroy(_content!.onChanged { [unowned self] in
      contentChildren = _content!.widgets
    })
  }

  override open func performLayout(constraints: BoxConstraints) -> DSize2 {
    var maxSize = DSize2.zero
    for child in contentChildren {
      child.layout(constraints: constraints)
      if child.layoutedSize.width > maxSize.width {
        maxSize.width = child.layoutedSize.width
      }
      if child.layoutedSize.height > maxSize.height {
        maxSize.height = child.layoutedSize.height
      }
    }
    return maxSize
  }
}