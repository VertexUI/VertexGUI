import Foundation
import VisualAppBase
import ReactiveProperties
import GfxMath

extension DeveloperTools {
  public class MainView: ContentfulWidget {
    private let inspectedRoot: Root

    private let store = DeveloperTools.Store()

    /*private var messages = WidgetBus<WidgetInspectionMessage>.MessageBuffer()
    private var widgetLifecycleMethodInvocationSignalBuffer = Bus<Widget.LifecycleMethodInvocationSignal>.MessageBuffer()
    @MutableProperty
    private var widgetLifecycleMethodInvocationSignalGroups: [Int: Widget.LifecycleMethodInvocationSignalGroup] = [:]*/

    public init(_ inspectedRoot: Root) {
      self.inspectedRoot = inspectedRoot

      /*_ = onDestroy(self.inspectedRoot.widgetContext!.inspectionBus.pipe(into: messages))

      self.inspectedRoot.widgetContext!.lifecycleMethodInvocationSignalBus.pipe(widgetLifecycleMethodInvocationSignalBuffer)

      _ = onDestroy(widgetLifecycleMethodInvocationSignalBuffer.onMessageAdded { [unowned self] in
        if (widgetLifecycleMethodInvocationSignalGroups[$0.invocationId] == nil) {
          widgetLifecycleMethodInvocationSignalGroups[$0.invocationId] = Widget.LifecycleMethodInvocationSignalGroup(
            method: $0.method, invocationId: $0.invocationId, signals: [$0])
        } else {
          widgetLifecycleMethodInvocationSignalGroups[$0.invocationId]!.signals.append($0)
        }
      })*/
    }

    @ExpDirectContentBuilder override public var content: ExpDirectContent {
      Container().experimentalWith(styleProperties: {
        (\.$direction, .column)
        (\.$alignContent, .stretch)
        (\.$overflowY, .scroll)
      }).withContent { [unowned self] in
        buildMenu()
        buildActiveView()
      }.provide(dependencies: store, inspectedRoot)
    }

    func buildMenu() -> Widget {
      Container().withContent {
        MainRoute.allCases.map {
          buildMenuItem($0)
        }
      }
    }

    func buildMenuItem(_ route: MainRoute) -> Widget {
      Container().with(classes: ["menu-item"]).onClick { [unowned self] in
        store.commit(.setActiveMainRoute(route))
      }.withContent {
        Text(route.rawValue)
      }
    }

    @ExpDirectContentBuilder func buildActiveView() -> ExpDirectContent {
      Dynamic(store.$state.activateMainRoute) { [unowned self] in
        switch store.state.activateMainRoute {
        /*case .performance:
          DeveloperTools.PerformanceView()*/
        case .inspector:
          DeveloperTools.InspectorView()
        }
      }
    }

    override public var experimentalStyle: Experimental.Style {
      Experimental.Style("&") {
        (\.$background, theme.backgroundColor)
        (\.$foreground, theme.textColorOnBackground)
      } nested: {
        Experimental.Style(".menu-item") {
          (\.$background, theme.primaryColor)
          (\.$fontWeight, .bold)
          (\.$padding, Insets(all: 16))
        } nested: {
          Experimental.Style("&:hover") {
            (\.$background, theme.primaryColor.darkened(30))
          }
        }

        theme.experimentalStyles
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
}