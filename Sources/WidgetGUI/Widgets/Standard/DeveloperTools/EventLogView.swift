import CustomGraphicsMath

public class EventLogView: SingleChildWidget {
  private let inspectedRoot: Root

  @ObservableProperty
  private var messages: [WidgetInspectionMessage]

  public init(_ inspectedRoot: Root, messages: ObservableProperty<[WidgetInspectionMessage]>) {
    self.inspectedRoot = inspectedRoot
    self._messages = messages
  }

  override public func buildChild() -> Widget {
    ScrollArea(scrollX: .Never) { [unowned self] in
      ObservingBuilder($messages) {
        Column {
          messages.map {
            buildInspectionMessageItem(message: $0)
          }
        }
      }
    }
  }

  private func buildInspectionMessageItem(message: WidgetInspectionMessage) -> Widget {
    MouseArea {
      Border(bottom: 1, color: Color(0, 0, 0, 40)) {
        Background(fill: .White) {
          Padding(all: 16) {
            Text("\(message.sender): \(message.content)")
          }
        }
      }
    } onClick: { _ in
      message.sender.flashHighlight()
    }
  }
}