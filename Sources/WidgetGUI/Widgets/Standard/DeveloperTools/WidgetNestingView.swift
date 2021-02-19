import GfxMath
import ReactiveProperties
import Events

public class WidgetNestingView: ComposedWidget {
  private let inspectedWidget: Widget
  private let depth: Int
  @MutableProperty
  private var expanded = false

  public let onInspect = WidgetEventHandlerManager<Widget>()

  public init(_ inspectedWidget: Widget, depth: Int = 0) {
    self.inspectedWidget = inspectedWidget
    self.depth = depth
    if depth < 10 {
      self.expanded = true
    }
    super.init()
  }

  override public func performBuild() {
    rootChild = Container(styleProperties: { _ in
      (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
    }) { [unowned self] in
      Container(classes: ["infoContainer"], styleProperties: {
        (SimpleLinearLayout.ParentKeys.alignContent, SimpleLinearLayout.Align.center)
        ($0.padding, Insets(left: 16))
      }) {
        MaterialDesignIcon(.menuDown).with(styleProperties: {
          ($0.foreground, Color.white)
        })

        Text("\(String(describing: inspectedWidget))").with(styleProperties: {
          ($0.foreground, developerToolsTheme.textColorOnBackground)
          ($0.padding, Insets(all: 16))
        })
      }.onClick {
        expanded = !expanded
      }

      Container(styleProperties: {
        (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
        ($0.padding, Insets(left: 16))
      }) {
        ReactiveContent($expanded) {
          if expanded {
            inspectedWidget.children.map { 
              WidgetNestingView($0, depth: depth + 1).onInspect.chain {
                onInspect.invokeHandlers($0)
              } 
            }
          } else {
            Space(.zero)
          }
        }
      }
    }
  }

  override public func buildStyle() -> Style {
    Style("&") {
      Style(".infoContainer") {
        ($0.background, Color.transparent)

        Style("&:hover") {
          ($0.background, developerToolsTheme.backgroundColor.darkened(10))
        }
      }
    }
  }
}