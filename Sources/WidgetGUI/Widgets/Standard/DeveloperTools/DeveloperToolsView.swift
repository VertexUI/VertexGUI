import Foundation
import VisualAppBase
import ReactiveProperties

public class DeveloperToolsView: SingleChildWidget {
  private let inspectedRoot: Root

  @MutableProperty
  private var activeTab: Tab = .Lifecycle
  
  private var messages = WidgetBus<WidgetInspectionMessage>.MessageBuffer()
  private var widgetLifecycleInvocationInfoBuffer = Bus<Widget.LifecycleMethodInvocationSignal>.MessageBuffer()
  //@MutableProperty
  //private var aggregatedWidgetLifecycleInvocationInfo:

  @MutableProperty
  private var inspectedWidget: Widget?

  public init(_ inspectedRoot: Root) {
    self.inspectedRoot = inspectedRoot
    super.init()
    _ = onDestroy(self.inspectedRoot.widgetContext!.inspectionBus.pipe(into: messages))
    self.inspectedRoot.widgetContext!.lifecycleMethodInvocationSignalBus.pipe(widgetLifecycleInvocationInfoBuffer)
  }

  override public func buildChild() -> Widget {
    Experimental.SimpleRow { [unowned self] in
      Experimental.DefaultTheme()

      Column(spacing: 16) {
        Row {
          Button {
            Text("Inspector")
          } onClick: { _ in
            activeTab = .Inspector
          }

          Button {
            Text("Event Cumulation")
          } onClick: { _ in
            activeTab = .EventRoll
          }

          Button {
            Text("Event Log")
          } onClick: { _ in
            activeTab = .EventLog
          }

          Flex.Item(grow: 1) {
            Space(.zero)
          }
          
          //LiveText { "fps: \(self.context.realFps)" }
        }

        ObservingBuilder($activeTab) {
          switch activeTab {
          case .Inspector:
            InspectorView(inspectedRoot).onInspectWidget.chain {
              inspectedWidget = $0
            }
          case .EventRoll:
            EventCumulationView(inspectedRoot)
          case .EventLog:
            Space(.zero)
            /*EventLogView(inspectedRoot, messages: $bufferedMessages.observable) {
              inspectedWidget = $0
            }*/
          case .Lifecycle:
            LifecycleView(widgetLifecycleInvocationInfoBuffer)
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

  override public func destroySelf() {
    messages.clear()
    widgetLifecycleInvocationInfoBuffer.destroy()
    super.destroySelf()
  }

  deinit {
    print("DEINITIALIZED DEV TOOLS VIEW")
  }
}

extension DeveloperToolsView {
  enum Tab {
    case Inspector, EventRoll, EventLog, Lifecycle
  }
}
