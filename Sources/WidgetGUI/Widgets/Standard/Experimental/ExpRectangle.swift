import ExperimentalReactiveProperties
import VisualAppBase
import GfxMath

extension Experimental {
  public class Rectangle: Widget, LeafWidget {
    @ExperimentalReactiveProperties.ObservableProperty
    private var paint: Paint

    public init<P: ReactiveProperty>(paint paintProperty: P) where P.Value == Paint {
      super.init()
      self.$paint.bind(paintProperty)
    }

    override public func getBoxConfig() -> BoxConfig {
      // this is an arbitrary preffered size, the size should be set by whatever uses the Widget
      BoxConfig(preferredSize: DSize2(100, 100))
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
      constraints.constrain(self.boxConfig.preferredSize)
    }

    public func draw(_ drawingContext: DrawingContext) {
      drawingContext.drawRect(rect: DRect(min: .zero, size: size), paint: paint)
    }
  }
}