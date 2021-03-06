import VisualAppBase
import GfxMath
import ReactiveProperties

public class Drawing: LeafWidget {
  @ObservableProperty
  private var paint: Paint

  private let _draw: (DrawingContext) -> ()

  public init(draw: @escaping (DrawingContext) -> ()) {
      self._draw = draw
  }

  override public func performLayout(constraints: BoxConstraints) -> DSize2 {
    constraints.constrain(DSize2(40, 40)) // arbitrary size to see something when min size constraints is 0
  }

  override public func draw(_ drawingContext: DrawingContext) {
    _draw(drawingContext)
  }
}