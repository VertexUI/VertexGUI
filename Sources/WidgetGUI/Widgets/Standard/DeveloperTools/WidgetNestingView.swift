import GfxMath
import ReactiveProperties
import Events

extension DeveloperTools {
  public class WidgetNestingView: ComposedWidget {
    @Inject
    var store: DeveloperTools.Store

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
      rootChild = Container().with(styleProperties: { _ in
        (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
      }).withContent { [unowned self] _ in
        Container().with(classes: ["infoContainer"], styleProperties: { _ in
          (SimpleLinearLayout.ParentKeys.alignContent, SimpleLinearLayout.Align.center)
        }).withContent { _ in
          MaterialDesignIcon(.menuDown).with(styleProperties: {
            ($0.foreground, Color.white)
            ($0.fontSize, 24.0)
            ($0.padding, Insets(left: 16))
          }).onClick {
            expanded = !expanded
          }

          Text("\(String(describing: inspectedWidget))").with(styleProperties: {
            ($0.foreground, developerToolsTheme.textColorOnBackground)
            ($0.padding, Insets(all: 16))
          }).onClick {
            store.commit(.setInspectedWidget(inspectedWidget))
          }
        }

        Container().with(styleProperties: {
          (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
          ($0.padding, Insets(left: 16))
        }).withContent {
          Dynamic($expanded) {
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

    override public var style: Style {
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
}