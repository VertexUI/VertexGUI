import SwiftGUI 

public class MainView: SingleChildWidget {
  @MutableProperty
  private var counter = 0

  override public func buildChild() -> Widget {
    Experimental.Container { [unowned self] in
      Experimental.DefaultTheme()

      Center {
        Experimental.Button {
          ObservingBuilder($counter) {
            Experimental.Text("Hello world \(counter)")
          }
        } onClick: {
          counter += 1
        }
      }
    }
  }
}