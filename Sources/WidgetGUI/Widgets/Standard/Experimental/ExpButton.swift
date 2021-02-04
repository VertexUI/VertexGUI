import GfxMath
import VisualAppBase

extension Experimental {
  public class Button: ComposedWidget, ExperimentalStylableWidget {
    private let childBuilder: SingleChildContentBuilder.ChildBuilder

    override public var experimentalSupportedStyleProperties: Experimental.StylePropertySupportDefinitions {
      Experimental.StylePropertySupportDefinitions {
        (StyleKeys.padding, type: .specific(Insets.self))
        (StyleKeys.backgroundFill, type: .specific(Color.self))
      }
    }

    public init(
      classes: [String]? = nil,
      @Experimental.StylePropertiesBuilder styleProperties stylePropertiesBuilder: (StyleKeys.Type) -> Experimental.StyleProperties = { _ in [] },
      @SingleChildContentBuilder content contentBuilder: @escaping () -> SingleChildContentBuilder.Result,
      onClick onClickHandler: (() -> ())? = nil) {
        let result = contentBuilder()
        self.childBuilder = result.child
        super.init()
        self.experimentalProvidedStyles.append(contentsOf: result.experimentalStyles)
        if let classes = classes {
          self.classes = classes
        }
        self.with(stylePropertiesBuilder(StyleKeys.self))
        if let handler = onClickHandler {
          _ = self.onClick(handler)
        }
    }

    override public func performBuild() {
      rootChild = Experimental.Container(styleProperties: {
        ($0.padding, stylePropertyValue(reactive: StyleKeys.padding))
        ($0.backgroundFill, stylePropertyValue(reactive: StyleKeys.backgroundFill))
      }) { [unowned self] in
        childBuilder()
      }
    }

    override public func renderContent() -> RenderObject? {
      return super.renderContent()
    }

    public typealias StyleKeys = Experimental.Container.StyleKeys
  }
}