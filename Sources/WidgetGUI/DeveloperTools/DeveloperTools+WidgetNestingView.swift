import GfxMath
import Events

extension DeveloperTools {
  public class WidgetNestingView: ComposedWidget {
    @Inject var store: DeveloperTools.Store

    private let inspectedWidget: Widget
    private let depth: Int
    @State private var expanded = false

    public init(_ inspectedWidget: Widget, depth: Int = 0) {
      self.inspectedWidget = inspectedWidget
      self.depth = depth
      if depth < 10 {
        self.expanded = true
      }
      super.init()
    }

    @Compose override public var content: ComposedContent {
      Container().with(styleProperties: {
        (\.$direction, .column)
      }).withContent {

        Container().with(classes: ["info-container"]).with(styleProperties: {
          (\.$alignContent, .center)
        }).withContent { _ in

          MaterialDesignIcon(.menuDown).with(classes: ["expand-icon"]).onClick { [unowned self] in
            expanded = !expanded
          }

          Text("\(String(describing: inspectedWidget))").with(classes: ["description-text"]).onClick { [unowned self] in
            store.commit(.setInspectedWidget(inspectedWidget))
          }
        }

        Container().with(styleProperties: {
          (\.$direction, .column)
          (\.$padding, Insets(left: 16))
        }).withContent {
          Dynamic($expanded.publisher) { [unowned self] in
            if expanded {
              inspectedWidget.children.map { [unowned self] in
                WidgetNestingView($0, depth: depth + 1)
              }
            } else {
              Space(.zero)
            }
          }
        }
      }
    }

    override public var style: Style {
      Style("&") {} nested: {
        Style(".info-container") {} nested: {
          Style("&:hover") {
            (\.$background, theme.backgroundColor.darkened(10))
          }
        }

        Style(".expand-icon") {
          (\.$foreground, .white)
          (\.$fontSize, 24.0)
          (\.$padding, Insets(left: 16))
        }

        Style(".description-text") {
          (\.$foreground, theme.textColorOnBackground)
          (\.$padding, Insets(all: 16))
        }
      }
    }
  }
}