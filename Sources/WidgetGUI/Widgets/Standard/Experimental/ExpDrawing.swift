import VisualAppBase
import GfxMath
import ExperimentalReactiveProperties

extension Experimental {
  public class Drawing: Widget, LeafWidget {
    @ExperimentalReactiveProperties.ObservableProperty
    private var paint: Paint

    private let _draw: (DrawingContext) -> ()

    public init(
      classes: [String]? = nil,
      @Experimental.StylePropertiesBuilder styleProperties buildStyleProperties: (StyleKeys.Type) -> Experimental.StyleProperties = { _ in [] },
      draw: @escaping (DrawingContext) -> ()) {
        self._draw = draw
        super.init()
        if let classes = classes {
          self.classes.append(contentsOf: classes)
        }
        self.with(buildStyleProperties(StyleKeys.self))
    }

    override public func getContentBoxConfig() -> BoxConfig {
      // size is arbitrary, should be chosen by parent
      BoxConfig(preferredSize: DSize2(100, 100))
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
      constraints.constrain(boxConfig.preferredSize)
    }

    public func draw(_ drawingContext: DrawingContext) {
      _draw(drawingContext)
    }
  }
}