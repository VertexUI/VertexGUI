import Foundation
import VisualAppBase

public class DeveloperToolsView: SingleChildWidget {
  private let inspectedRoot: Root

  @MutableProperty
  private var activeTab: Tab = .EventRoll
  
  private var messages = WidgetBus<WidgetInspectionMessage>.MessageBuffer()

  @MutableProperty
  private var inspectedWidget: Widget?

  public init(_ inspectedRoot: Root) {
    self.inspectedRoot = inspectedRoot
    super.init()
    self.inspectedRoot.widgetContext!.inspectionBus.pipe(into: messages)
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
            EventRollView(inspectedRoot, messageBuffer: messages)
          case .EventLog:
            /*EventLogView(inspectedRoot, messages: $bufferedMessages.observable) {
              inspectedWidget = $0
            }*/
            Space(.zero)
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
