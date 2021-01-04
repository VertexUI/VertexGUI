extension Experimental {
  public class Button: ComposedWidget, StylableWidget, GUIMouseEventConsumer {
    private let childBuilder: () -> ChildBuilder.Result

    public let onClick = WidgetEventHandlerManager<Void>()

    public init(@ChildBuilder child childBuilder: @escaping () -> ChildBuilder.Result, onClick onClickHandler: (() -> ())? = nil) {
      self.childBuilder = childBuilder
      if let handler = onClickHandler {
        self.onClick.addHandler(handler)
      }
    }

    override public func performBuild() {
      let result = childBuilder()
      providedStyles.append(contentsOf: result.styles)
      rootChild = Padding(all: 16) {
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
  }
}