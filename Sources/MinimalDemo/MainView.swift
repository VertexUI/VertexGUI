import SwiftGUI 

public class MainView: SingleChildWidget {
  @MutableProperty
  private var counter = 0

  override public func buildChild() -> Widget {
    Center { [unowned self] in
      Button {
        ObservingBuilder($counter) {
          Text("Hello world \(counter)")
        }
      } onClick: { _ in
        counter += 1
      }
    }
  }
}