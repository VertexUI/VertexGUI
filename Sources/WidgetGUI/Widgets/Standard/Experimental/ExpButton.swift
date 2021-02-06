import GfxMath
import VisualAppBase

extension Experimental {
  public class Button: ComposedWidget, ExperimentalStylableWidget {
    public init(
      classes: [String]? = nil,
      @Experimental.StylePropertiesBuilder styleProperties stylePropertiesBuilder: (StyleKeys.Type) -> Experimental.StyleProperties = { _ in [] },
      @SingleChildContentBuilder content contentBuilder: @escaping () -> SingleChildContentBuilder.Result,
      onClick onClickHandler: (() -> ())? = nil) {
        let result = contentBuilder()
        super.init()
        self.rootChild = result.child()
        self.experimentalProvidedStyles.append(contentsOf: result.experimentalStyles)
        if let classes = classes {
          self.classes = classes
        }
        self.with(stylePropertiesBuilder(StyleKeys.self))
        if let handler = onClickHandler {
          _ = self.onClick(handler)
        }
    }

    override public func renderContent() -> RenderObject? {
      return super.renderContent()
    }

    public typealias StyleKeys = Experimental.AnyDefaultStyleKeys
  }
}