extension DeveloperTools {
  public class MessagesView: ComposedWidget {
    @Inject private var inspectedRoot: Root

    @Compose override public var content: ComposedContent {
      Container().withContent {
        List(items: inspectedRoot.debugManager.$messages.immutable).withContent {
          List<DebugMessage>.itemSlot { item in
            Container().withContent {
              Text(item.message)
              Text(String(describing: item.sender))
            }.onMouseEnter {
              item.sender.debugHighlight = true
            }.onMouseLeave {
              item.sender.debugHighlight = false
            }
          }
        }
      }
    }
  }
}