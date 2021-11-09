import Foundation
import GfxMath

extension DeveloperTools {
  public class MainView: ComposedWidget {
    private let inspectedRoot: Root

    @State private var activeMainRoute: MainRoute = .inspector

    private let store = DeveloperTools.Store()

    /*private var messages = WidgetBus<WidgetInspectionMessage>.MessageBuffer()
    private var widgetLifecycleMethodInvocationSignalBuffer = Bus<Widget.LifecycleMethodInvocationSignal>.MessageBuffer()
    @MutableProperty
    private var widgetLifecycleMethodInvocationSignalGroups: [Int: Widget.LifecycleMethodInvocationSignalGroup] = [:]*/

    public init(_ inspectedRoot: Root) {
      self.inspectedRoot = inspectedRoot
      super.init()
      provide(dependencies: inspectedRoot, store)

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

    @Compose override public var content: ComposedContent {
      Container().with(styleProperties: {
        (\.$direction, .column)
        (\.$alignContent, .stretch)
        (\.$overflowY, .scroll)
      }).withContent {
        buildMenu()
        buildActiveView()
      }
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
        activeMainRoute = route
      }.withContent {
        Text(route.rawValue)
      }
    }

    @DirectContentBuilder func buildActiveView() -> DirectContent {
      Dynamic($activeMainRoute.immutable) { [weak self] in
        switch self?.activeMainRoute {
        case .inspector:
          DeveloperTools.InspectorView()
        case .messages:
          DeveloperTools.MessagesView()
        default: 
          Text("none")
        }
      }
    }

    override public var style: Style {
      Style("&") {
        (\.$background, theme.backgroundColor)
        (\.$foreground, theme.textColorOnBackground)
      } nested: {
        Style(".menu-item") {
          (\.$background, theme.primaryColor)
          (\.$fontWeight, .bold)
          (\.$padding, Insets(all: 16))
        } nested: {
          Style("&:hover") {
            (\.$background, theme.primaryColor.darkened(30))
          }
        }

        theme.styles
      }
    }
  }
}