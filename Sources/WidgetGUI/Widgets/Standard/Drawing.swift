import VisualAppBase
import GfxMath
import ReactiveProperties

public class Drawing: LeafWidget {
  @ObservableProperty
  private var paint: Paint

  private let _draw: (DrawingContext) -> ()

  public init(
    classes: [String]? = nil,
    @StylePropertiesBuilder styleProperties buildStyleProperties: (StyleKeys.Type) -> StyleProperties = { _ in [] },
    draw: @escaping (DrawingContext) -> ()) {
      self._draw = draw
      super.init()
      if let classes = classes {
        self.classes.append(contentsOf: classes)
      }
      self.directStyleProperties.append(buildStyleProperties(StyleKeys.self))
  }

  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    constraints.constrain(DSize2(40, 40)) // arbitrary size to see something when min size constraints is 0
  }

  override public func draw(_ drawingContext: DrawingContext) {
    _draw(drawingContext)
  }
}