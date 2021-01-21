import VisualAppBase
import ExperimentalReactiveProperties
import GfxMath

extension Experimental {
  public class Background: ComposedWidget, ExperimentalStylableWidget {
    @ObservableProperty
    private var fill: Color?
    
    override private init(contentBuilder: () -> SingleChildContentBuilder.Result) {
        super.init(contentBuilder: contentBuilder)
        self._fill = stylePropertiesResolver[reactive: StyleKeys.fill]
        _ = self.$fill.onChanged { [unowned self] _ in
          invalidateRenderState()
        }
    }

    public convenience init(
      configure: ((Experimental.Background) -> ())? = nil,
      @SingleChildContentBuilder content contentBuilder: @escaping () -> SingleChildContentBuilder.Result) {
        self.init(contentBuilder: contentBuilder)
        if let configure = configure {
          configure(self)
        }
    }

    public convenience init(
      classes: [String]? = nil,
      @Experimental.StylePropertiesBuilder styleProperties stylePropertiesBuilder: (StyleKeys.Type) -> Experimental.StyleProperties = { _ in [] },
      @SingleChildContentBuilder content contentBuilder: @escaping () -> SingleChildContentBuilder.Result) {
        self.init(contentBuilder: contentBuilder)
        if let classes = classes {
          self.classes = classes
        }
        self.with(stylePropertiesBuilder(StyleKeys.self))
    }

    override public func renderContent() -> RenderObject? {
      ContainerRenderObject {
        RenderStyleRenderObject(fillColor: fill ?? .transparent) {
          RectangleRenderObject(globalBounds)
        }

        rootChild?.render()
      }
    }

    public enum StyleKeys: String, StyleKey, ExperimentalDefaultStyleKeys {
      case fill
    }
  }
}