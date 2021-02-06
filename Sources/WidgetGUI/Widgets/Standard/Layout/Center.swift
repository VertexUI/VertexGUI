import GfxMath

public class Center: SingleChildWidget {
  private var childBuilder: () -> Widget

  public init(@WidgetBuilder child childBuilder: @escaping () -> Widget) {
    self.childBuilder = childBuilder
  }

  override open func buildChild() -> Widget {

    childBuilder()
  }

  override public func getContentBoxConfig() -> BoxConfig {

    BoxConfig(preferredSize: child.boxConfig.preferredSize, minSize: .zero, maxSize: .infinity)
  }

  override open func performLayout(constraints: BoxConstraints) -> DSize2 {

    child.layout(constraints: BoxConstraints(minSize: DSize2.zero, maxSize: constraints.maxSize))

    let ownSize = constraints.constrain(child.bounds.size)

    child.position = DVec2(ownSize - child.bounds.size) / 2

    return ownSize
  }
}
