import ExperimentalReactiveProperties
import VisualAppBase
import GfxMath

extension Experimental {
  public class Rectangle: Widget, LeafWidget {
    override public func getBoxConfig() -> BoxConfig {
      BoxConfig(preferredSize: DSize2(100, 100))
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
      constraints.constrain(self.boxConfig.preferredSize)
    }

    public func draw(_ drawingContext: DrawingContext) {
      drawingContext.drawRect(rect: DRect(min: .zero, size: size), paint: Paint(color: .blue))
    }
  }
}