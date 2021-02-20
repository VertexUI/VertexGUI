import GfxMath

extension DeveloperTools {
  public class InspectorView: ComposedWidget {
    @Inject
    var inspectedRoot: Root
    @Inject
    var store: DeveloperTools.Store

    override public func performBuild() {
      rootChild = Container { [unowned self] in
        DeveloperTools.WidgetNestingView(inspectedRoot.rootWidget)

        DeveloperTools.WidgetPropertiesView().with(styleProperties: { _ in
          (SimpleLinearLayout.ChildKeys.grow, 1.0)
        })
      }
    }
  }
}