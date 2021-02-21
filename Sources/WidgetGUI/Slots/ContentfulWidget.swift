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
}