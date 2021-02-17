public class InspectorView: ComposedWidget {
  private let inspectedRoot: Root

  public let onInspectWidget = WidgetEventHandlerManager<Widget>()
  
  public init(_ inspectedRoot: Root) {
    self.inspectedRoot = inspectedRoot
    super.init()
  }

  /*override public func buildChild() -> Widget {
    Background(fill: .white) { [unowned self] in
      Column {
        WidgetNestingView(inspectedRoot.rootWidget).onInspect.chain {
          onInspectWidget.invokeHandlers($0)
        }
      }
    }
  }*/
}