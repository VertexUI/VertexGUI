import GfxMath

extension DeveloperTools {
  public class InspectorView: ComposedWidget {
    @Inject var inspectedRoot: Root
    @Inject var store: DeveloperTools.Store

    @Compose override public var content: ComposedContent {
      Container().withContent {
        DeveloperTools.WidgetNestingView(inspectedRoot.rootWidget)
      }
    }

    override public var style: Style {
      Style("&") {
        (\.$overflowY, .scroll)
      }
    }
  }
}