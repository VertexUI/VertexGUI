public class InspectorView: SingleChildWidget {
  private let inspectedRoot: Root
  
  public init(_ inspectedRoot: Root) {
    self.inspectedRoot = inspectedRoot
  }

  override public func buildChild() -> Widget {
    Background(fill: .White) { [unowned self] in
      Column {
        WidgetNestingView(inspectedRoot.rootWidget)
      }
    }
  }
}