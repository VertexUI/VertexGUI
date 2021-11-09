import Foundation
import GfxMath

extension DeveloperTools {
  public class MainView: ComposedWidget {
    private let inspectedRoot: Root

    @State private var activeMainRoute: MainRoute = .inspector

    private let store = DeveloperTools.Store()

    public init(_ inspectedRoot: Root) {
      self.inspectedRoot = inspectedRoot
      super.init()
      provide(dependencies: inspectedRoot, store)
    }

    @Compose override public var content: ComposedContent {
      Container().with(styleProperties: {
        (\.$direction, .column)
        (\.$alignContent, .stretch)
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
        (\.$height, .rh(100))
        (\.$overflowY, .scroll)
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