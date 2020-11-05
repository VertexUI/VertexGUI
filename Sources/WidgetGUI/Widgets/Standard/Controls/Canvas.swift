import VisualAppBase
import CustomGraphicsMath

public class PixelCanvas: Widget {
  private var content: Image? = nil
  
  public init() {
    super.init()
    _ = self.onLayoutingFinished { [unowned self] _ in
      updateContentSize()
    }
  }

  override public func getBoxConfig() -> BoxConfig {
    // this is an arbitrary size...
    BoxConfig(preferredSize: DSize2(10, 10))
  }

  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    constraints.constrain(boxConfig.preferredSize)
  }

  private func updateContentSize() {
    content = Image(width: Int(width), height: Int(height), value: 0)
  }
  
  public func setPixel(at position: SIMD2<Int>, to color: Color) {
    content![position.x, position.y, 0] = color.r
    content![position.x, position.y, 1] = color.g
    content![position.x, position.y, 2] = color.b
    content![position.x, position.y, 3] = color.a
  }

  override public func renderContent() -> RenderObject? {
    if let content = content {
      return RenderStyleRenderObject(fill: FixedRenderValue(.Image(content, position: globalBounds.min))) {
        RectangleRenderObject(globalBounds)
      }
    } else {
      return nil
    }
  }
}