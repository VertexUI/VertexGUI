import Foundation
import VisualAppBase
import ReactiveProperties
import GfxMath

public class DeveloperToolsView: ContentfulWidget {
  private let inspectedRoot: Root

  private let store = DeveloperTools.Store()

  @MutableProperty
  private var activeTab: Tab = .performance
  
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

  @ExpDirectContentBuilder override public var content: ExpDirectContent {
    Container().with(styleProperties: {
      (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
      (SimpleLinearLayout.ParentKeys.alignContent, SimpleLinearLayout.Align.stretch)
      ($0.overflowY, Overflow.scroll)
    }).withContent { [unowned self] in
      buildMenu()
      buildActiveView()
    }.provide(dependencies: store, inspectedRoot)
  }

  func buildMenu() -> Widget {
    Container().with(styleProperties: { _ in

    }).withContent {
      Tab.allCases.map {
        buildMenuItem($0)
      }
    }
  }

  func buildMenuItem(_ tab: Tab) -> Widget {
    Container().with(classes: ["menu-item"]).onClick { [unowned self] in
      activeTab = tab
    }.withContent {
      Text(tab.rawValue)
    }
  }

  @ExpDirectContentBuilder func buildActiveView() -> ExpDirectContent {
    Dynamic($activeTab) { [unowned self] in
      switch activeTab {
      case .performance:
        DeveloperTools.PerformanceView()
      case .inspector:
        DeveloperTools.InspectorView()
      }
    }
  }

  override public var style: Style {
    Style("&") {
      ($0.background, developerToolsTheme.backgroundColor)
      ($0.foreground, developerToolsTheme.textColorOnBackground)

      Style(".menu-item") {
        ($0.background, developerToolsTheme.primaryColor)
        ($0.fontWeight, FontWeight.bold)
        ($0.padding, 16)

        Style("&:hover") {
          ($0.background, developerToolsTheme.primaryColor.darkened(30))
        }
      }

      developerToolsTheme.styles
    }
  }

  /*override public func buildChild() -> Widget {
    Experimental.SimpleRow { [unowned self] in
      DefaultTheme()

      Column(spacing: 16) {
        Row {
          Button().withContent {
            Text("Inspector")
          } onClick: {
            activeTab = .Inspector
          }

          Button().withContent {
            Text("Event Cumulation")
          } onClick: {
            activeTab = .EventRoll
          }

          Button().withContent {
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
  enum Tab: String, CaseIterable {
    case inspector, performance
  }
}
