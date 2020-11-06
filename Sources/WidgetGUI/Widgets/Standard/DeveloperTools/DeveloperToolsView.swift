import VisualAppBase

public class DeveloperToolsView: SingleChildWidget {
  private let inspectedRoot: Root

  @MutableProperty
  private var activeTab: Tab = .EventRoll
  
  @MutableProperty
  private var bufferedMessages: [WidgetInspectionMessage] = []

  @MutableProperty
  private var inspectedWidget: Widget?

  public init(_ inspectedRoot: Root) {
    self.inspectedRoot = inspectedRoot
    super.init()
    _ = onDestroy(self.inspectedRoot.widgetContext!.inspectionBus.onMessage { [unowned self] in
      bufferedMessages.append($0)
    })
  }

  override public func buildChild() -> Widget {
    Row { [unowned self] in
      Column(spacing: 16) {
        Row {
          Button {
            Text("Inspector")
          } onClick: { _ in
            activeTab = .Inspector
          }

          Button {
            Text("Event Roll")
          } onClick: { _ in
            activeTab = .EventRoll
          }

          Button {
            Text("Event Log")
          } onClick: { _ in
            activeTab = .EventLog
          }
        }

        ObservingBuilder($activeTab) {
          switch activeTab {
          case .Inspector:
            InspectorView(inspectedRoot)
          case .EventRoll:
            EventRollView(inspectedRoot, messages: $bufferedMessages.observable)
          case .EventLog:
            EventLogView(inspectedRoot, messages: $bufferedMessages.observable) {
              inspectedWidget = $0
            }
          }
        }
      }

      ObservingBuilder($inspectedWidget) {
        if let inspectedWidget = inspectedWidget {
          WidgetDetailView(inspectedWidget)
        } else {
          Space(.zero)
        }
      }
    }
  }
}

extension DeveloperToolsView {
  enum Tab {
    case Inspector, EventRoll, EventLog
  }
}
