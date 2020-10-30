import VisualAppBase

public class DeveloperToolsView: SingleChildWidget {
  private let inspectedRoot: Root
  
  public init(_ inspectedRoot: Root) {
    self.inspectedRoot = inspectedRoot
  }

  override public func buildChild() -> Widget {
    InspectorView(inspectedRoot)
  }
}