import GfxMath

extension DeveloperTools {
  public class InspectorView: ContentfulWidget {
    @Inject var inspectedRoot: Root
    @Inject var store: DeveloperTools.Store

    @DirectContentBuilder override public var content: DirectContent {
      Container().withContent {
        //DeveloperTools.WidgetNestingView(inspectedRoot.rootWidget)
      }
    }
  }
}