extension Experimental {
  public class Button: ComposedWidget, ExperimentalStylableWidget, GUIMouseEventConsumer {
    private let childBuilder: () -> ChildBuilder.Result

    public let onClick = WidgetEventHandlerManager<Void>()

    public init(
      classes: [String]? = nil,
      @Experimental.StylePropertiesBuilder styleProperties stylePropertiesBuilder: (StyleKeys.Type) -> [Experimental.StyleProperty] = { _ in [] },
      @ChildBuilder child childBuilder: @escaping () -> ChildBuilder.Result,
      onClick onClickHandler: (() -> ())? = nil) {
        self.childBuilder = childBuilder
        super.init()
        if let handler = onClickHandler {
          self.onClick.addHandler(handler)
        }
        if let classes = classes {
          self.classes = classes
        }
        self.experimentalDirectStyleProperties.append(contentsOf: stylePropertiesBuilder(StyleKeys.self))
    }

    override public func performBuild() {
      let result = childBuilder()
      providedStyles.append(contentsOf: result.styles)
      rootChild = Experimental.Container(configure: { [unowned self] in
        $0.with(styleProperties: {
          ($0.padding, stylePropertyValue(StyleKeys.padding) ?? Insets(all: 16))
          ($0.backgroundFill, stylePropertyValue(StyleKeys.backgroundFill) ?? Insets(all: 16))
        })
      }) {
        result.child
      }
    }

    public func acceptsStyleProperties(_ properties: AnyStyleProperties) -> Bool {
      properties is AnyBackgroundStyleProperties || properties is AnyPaddingStyleProperties
    }

    public func consume(_ event: GUIMouseEvent) {
      if let _ = event as? GUIMouseButtonClickEvent {
        onClick.invokeHandlers()
      }
    }

    public enum StyleKeys: String, StyleKey, ExperimentalDefaultStyleKeys {
      case backgroundFill
      case padding
    }
  }
}