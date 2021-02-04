import Foundation
import VisualAppBase
import ReactiveProperties
import ExperimentalReactiveProperties

public class DeveloperToolsView: SingleChildWidget {
  private let inspectedRoot: Root

  @ReactiveProperties.MutableProperty
  private var activeTab: Tab = .Lifecycle
  
  private var messages = WidgetBus<WidgetInspectionMessage>.MessageBuffer()
  private var widgetLifecycleMethodInvocationSignalBuffer = Bus<Widget.LifecycleMethodInvocationSignal>.MessageBuffer()
  @ExperimentalReactiveProperties.MutableProperty
  private var widgetLifecycleMethodInvocationSignalGroups: [Int: Widget.LifecycleMethodInvocationSignalGroup] = [:]

  @ReactiveProperties.MutableProperty
  private var inspectedWidget: Widget?

  public init(_ inspectedRoot: Root) {
    self.inspectedRoot = inspectedRoot
    super.init()

    _ = onDestroy(self.inspectedRoot.widgetContext!.inspectionBus.pipe(into: messages))

    self.inspectedRoot.widgetContext!.lifecycleMethodInvocationSignalBus.pipe(widgetLifecycleMethodInvocationSignalBuffer)

    _ = onDestroy(widgetLifecycleMethodInvocationSignalBuffer.onMessageAdded { [unowned self] in
      if (widgetLifecycleMethodInvocationSignalGroups[$0.invocationId] == nil) {
        widgetLifecycleMethodInvocationSignalGroups[$0.invocationId] = Widget.LifecycleMethodInvocationSignalGroup(
          method: $0.method, invocationId: $0.invocationId, signals: [$0])
      } else {
        widgetLifecycleMethodInvocationSignalGroups[$0.invocationId]!.signals.append($0)
      }
    })
  }

  override public func buildChild() -> Widget {
    Experimental.SimpleRow { [unowned self] in
      Experimental.DefaultTheme()

      Column(spacing: 16) {
        Row {
          Experimental.Button {
            Text("Inspector")
          } onClick: {
            activeTab = .Inspector
          }

          Experimental.Button {
            Text("Event Cumulation")
          } onClick: {
            activeTab = .EventRoll
          }

          Experimental.Button {
            Text("Event Log")
          } onClick: {
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
            LifecycleView(widgetLifecycleMethodInvocationSignalBuffer, $widgetLifecycleMethodInvocationSignalGroups)
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
    widgetLifecycleMethodInvocationSignalBuffer.destroy()
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
