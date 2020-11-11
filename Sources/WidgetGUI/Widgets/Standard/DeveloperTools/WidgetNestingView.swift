import CustomGraphicsMath

public class WidgetNestingView: SingleChildWidget {
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
  }

  override public func buildChild() -> Widget {
    Column { [unowned self] in
      Row {
        MouseArea {
          Background(fill: .Yellow) {
            Padding(all: 8) {
              MaterialIcon(.menuDown)
            }
          }
        } onClick: { _ in
          expanded = !expanded
        }

        MouseArea {
          Background(fill: Color(0, 0, 255, 50)) {
            Padding(all: 8) {
              Text("\(String(describing: inspectedWidget))")
            }
          }
        } onClick: { _ in
          onInspect.invokeHandlers(inspectedWidget)
        }
      }

      ObservingBuilder($expanded) {
        if expanded && inspectedWidget.children.count > 0 {
          Padding(left: 16) {
            Column {
              inspectedWidget.children.map { 
                WidgetNestingView($0, depth: depth + 1).onInspect.chain {
                  onInspect.invokeHandlers($0)
                } 
              }
            }
          }
        } else {
          Space(.zero)
        }
      }
    }
  }
}