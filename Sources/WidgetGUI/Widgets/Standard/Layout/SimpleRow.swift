import CustomGraphicsMath

public class SimpleRow: Widget {
  private let childrenBuilder: () -> [Widget]
  
  public init(@WidgetBuilder children childrenBuilder: @escaping () -> [Widget]) {
    self.childrenBuilder = childrenBuilder
  }

  override public func build() {
    self.children = childrenBuilder()
  }

  override public func getBoxConfig() -> BoxConfig {
    var result = BoxConfig(preferredSize: .zero)
    for child in children {
      let childConfig = child.boxConfig
      result.preferredSize.width += childConfig.preferredSize.width
      result.minSize.width += childConfig.minSize.width
      result.maxSize.width += childConfig.maxSize.width

      if childConfig.preferredSize.height > result.preferredSize.height {
        result.preferredSize.height = childConfig.preferredSize.height
      }
      if childConfig.minSize.height > result.minSize.height {
        result.minSize.height = childConfig.minSize.height
      }
      if childConfig.maxSize.height > result.maxSize.height {
        result.maxSize.height = childConfig.maxSize.height
      }
    }
    return result
  }

  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    var totalSize = DSize2.zero
    for child in children {
      let childConstraints = BoxConstraints(
        minSize: .zero,
        maxSize: DSize2(constraints.maxWidth - totalSize.width, constraints.maxHeight)
      )
      child.layout(constraints: childConstraints)
      child.x = totalSize.width
      totalSize.width += child.width
      if child.height > totalSize.height {
        totalSize.height = child.height
      }
    }
    return totalSize
  }
}