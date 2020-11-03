public class WidgetDetailView: SingleChildWidget {
  private let inspectedWidget: Widget

  public init(_ inspectedWidget: Widget) {
    self.inspectedWidget = inspectedWidget
  }

  override public func buildChild() -> Widget {
    Column(spacing: 24) { [unowned self] in
      Text("Widget \(inspectedWidget)")

      Row(crossAlignment: .Center, spacing: 16) {
        Checkbox(bind: inspectedWidget.$debugLayout)
        
        Text("show bounds and size")
      }

      Row(crossAlignment: .Center, spacing: 16) {
        Text("layout debugging color")

        ColorPicker(bind: inspectedWidget.$layoutDebuggingColor.binding)
      }
    }
  }
}