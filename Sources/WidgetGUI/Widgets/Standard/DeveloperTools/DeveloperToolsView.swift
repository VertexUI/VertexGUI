import Foundation
import VisualAppBase
import ReactiveProperties
import ReactiveProperties

public class DeveloperToolsView: ComposedWidget {
  private let inspectedRoot: Root

  private let store = DeveloperTools.Store()

  @MutableProperty
  private var activeTab: Tab = .Lifecycle
  
  private var messages = WidgetBus<WidgetInspectionMessage>.MessageBuffer()
  private var widgetLifecycleMethodInvocationSignalBuffer = Bus<Widget.LifecycleMethodInvocationSignal>.MessageBuffer()
  @MutableProperty
  private var widgetLifecycleMethodInvocationSignalGroups: [Int: Widget.LifecycleMethodInvocationSignalGroup] = [:]

  @MutableProperty
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

  override public func performBuild() {
    rootChild = Container().with(styleProperties: {
      (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
      (SimpleLinearLayout.ParentKeys.alignContent, SimpleLinearLayout.Align.stretch)
      ($0.overflowY, Overflow.scroll)
    }).withContent { [unowned self] in
      DeveloperTools.InspectorView()
    }.provide(dependencies: store, inspectedRoot)
  }

  override public func buildStyle() -> Style {
    Style("&") {
      ($0.background, developerToolsTheme.backgroundColor)
      ($0.foreground, developerToolsTheme.textColorOnBackground)

      developerToolsTheme.styles
    }
  }

  /*override public func buildChild() -> Widget {
    Experimental.SimpleRow { [unowned self] in
      DefaultTheme()

      Column(spacing: 16) {
        Row {
          Button {
            Text("Inspector")
          } onClick: {
            activeTab = .Inspector
          }

          Button {
            Text("Event Cumulation")
          } onClick: {
            activeTab = .EventRoll
          }

          Button {
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
  }*/
}

extension DeveloperToolsView {
  enum Tab {
    case Inspector, EventRoll, EventLog, Lifecycle
  }
}
