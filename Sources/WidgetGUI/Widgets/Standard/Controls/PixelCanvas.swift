import VisualAppBase
import CustomGraphicsMath

public class PixelCanvas: Widget {
  private var content: Image
  public var contentSize: SIMD2<Int> {
    [content.width, content.height]
  }
  
  public init(_ contentSize: DSize2) {
    content = Image(width: Int(contentSize.width), height: Int(contentSize.height), value: 0)
  }

  override public func getBoxConfig() -> BoxConfig {
    // this is an arbitrary size...
    BoxConfig(preferredSize: DSize2(10, 10))
  }

  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    constraints.constrain(boxConfig.preferredSize)
  }

  public func resize(_ contentSize: DSize2) {
    // TODO: implement different resizing methods, add space around, crop center etc. to keep the content
    content = Image(width: Int(contentSize.width), height: Int(contentSize.height), value: 0)
  }

  public func clear() {
    content = Image(width: Int(content.width), height: Int(content.height), value: 0)
  }
  
  public func setPixel(at position: SIMD2<Int>, to color: Color) {
    content[position.x, position.y, 0] = color.r
    content[position.x, position.y, 1] = color.g
    content[position.x, position.y, 2] = color.b
    content[position.x, position.y, 3] = color.a
  }

  override public func renderContent() -> RenderObject? {
    //let resizedContent = content.resize(width: Int(width), height: Int(height))
    return RenderStyleRenderObject(fill: FixedRenderValue(.Image(content, position: globalBounds.min))) {
      RectangleRenderObject(globalBounds)
    }
  }
}