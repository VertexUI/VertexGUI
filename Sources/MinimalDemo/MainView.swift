import WidgetGUI

public class MainView: SingleChildWidget {
  @MutableProperty
  private var counter = 0

  override public func buildChild() -> Widget {
    ObservingBuilder($counter) { [unowned self] in
      Center {
        Button {
          Text("Hello world \(counter)")
        } onClick: { _ in
          counter += 1
        }
      }
    }
  }
}