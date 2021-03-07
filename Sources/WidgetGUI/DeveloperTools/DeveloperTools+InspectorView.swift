import GfxMath

extension DeveloperTools {
  public class InspectorView: ContentfulWidget {
    @Inject var inspectedRoot: Root
    @Inject var store: DeveloperTools.Store

    @ExpDirectContentBuilder override public var content: ExpDirectContent {
      Container().withContent { [unowned self] in
        DeveloperTools.WidgetNestingView(inspectedRoot.rootWidget)
      }
    }
  }
}