import GfxMath
import VisualAppBase

public class Button: ComposedWidget, StylableWidget {
  public init(
    classes: [String]? = nil,
    @StylePropertiesBuilder styleProperties stylePropertiesBuilder: (StyleKeys.Type) -> StyleProperties = { _ in [] },
    @SingleChildContentBuilder content contentBuilder: @escaping () -> SingleChildContentBuilder.Result,
    onClick onClickHandler: (() -> ())? = nil) {
      let result = contentBuilder()
      super.init()
      self.rootChild = result.child()
      self.providedStyles.append(contentsOf: result.styles)
      if let classes = classes {
        self.classes = classes
      }
      self.directStyleProperties.append(stylePropertiesBuilder(StyleKeys.self))
      if let handler = onClickHandler {
        _ = self.onClick(handler)
      }
  }

  override public func renderContent() -> RenderObject? {
    return super.renderContent()
  }

  public typealias StyleKeys = AnyDefaultStyleKeys
}