public class InspectorView: ComposedWidget {
  private let inspectedRoot: Root

  public let onInspectWidget = WidgetEventHandlerManager<Widget>()
  
  public init(_ inspectedRoot: Root) {
    self.inspectedRoot = inspectedRoot
    super.init()
  }

  override public func performBuild() {
    rootChild = WidgetNestingView(inspectedRoot.rootWidget).onInspect.chain { [unowned self] in
      onInspectWidget.invokeHandlers($0)
    }
  }
}