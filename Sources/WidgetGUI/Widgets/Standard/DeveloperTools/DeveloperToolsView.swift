import VisualAppBase

public class DeveloperToolsView: SingleChildWidget {
  private let inspectedRoot: Root

  @MutableProperty
  private var activeTab: Tab = .EventLog
  
  @MutableProperty
  private var bufferedMessages: [WidgetInspectionMessage] = []

  public init(_ inspectedRoot: Root) {
    self.inspectedRoot = inspectedRoot
    super.init()
    _ = onDestroy(self.inspectedRoot.widgetContext!.inspectionBus.onMessage { [unowned self] in
      bufferedMessages.append($0)
    })
  }

  override public func buildChild() -> Widget {
    Column(spacing: 16) { [unowned self] in
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
          EventRollView(inspectedRoot)
        case .EventLog:
          EventLogView(inspectedRoot, messages: $bufferedMessages)
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