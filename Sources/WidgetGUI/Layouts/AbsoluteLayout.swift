import GfxMath

public class AbsoluteLayout: Layout {
  override public func layout(constraints: BoxConstraints) -> DSize2 {
    var maxSize = DSize2.zero
    for widget in widgets {
      widget.layout(constraints: constraints)
      if widget.layoutedSize.width > maxSize.width {
        maxSize.width = widget.layoutedSize.width
      }
      if widget.layoutedSize.height > maxSize.height {
        maxSize.height = widget.layoutedSize.height
      }
    }
    return maxSize
  }
}