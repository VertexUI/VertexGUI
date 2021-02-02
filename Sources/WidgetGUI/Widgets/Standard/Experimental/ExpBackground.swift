import VisualAppBase
import ExperimentalReactiveProperties
import GfxMath

extension Experimental {
  public class Background: Widget, ExperimentalStylableWidget {
    @ExperimentalReactiveProperties.ObservableProperty
    private var fill: Color?

    @Reference
    private var backgroundRectangle: Widget
    private var foregroundChild: Widget
    
    private init(contentBuilder: () -> SingleChildContentBuilder.Result) {
        let content = contentBuilder()
        self.foregroundChild = content.child()
        super.init()
        self.experimentalProvidedStyles.append(contentsOf: content.experimentalStyles)
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

    override public func performBuild() {
      children = [
        Experimental.Rectangle(paint: ExperimentalReactiveProperties.ComputedProperty(compute: { [unowned self] in
          Paint(color: fill)
        }, dependencies: [$fill])).connect(ref: $backgroundRectangle),
        foregroundChild
      ]
    }

    override public func getBoxConfig() -> BoxConfig {
      foregroundChild.getBoxConfig()
    }

    override public func performLayout(constraints: BoxConstraints) -> DSize2 {
      foregroundChild.layout(constraints: constraints)
      backgroundRectangle.layout(constraints: BoxConstraints(size: foregroundChild.size))
      return foregroundChild.size
    }

    override public func renderContent() -> RenderObject? {
      ContainerRenderObject { [unowned self] in
        RenderStyleRenderObject(fillColor: fill ?? .transparent) {
          RectangleRenderObject(globalBounds)
        }

        children.map { $0.render(reason: .renderContentOfParent(self)) }
      }
    }

    public enum StyleKeys: String, StyleKey, ExperimentalDefaultStyleKeys {
      case fill
    }
  }
}