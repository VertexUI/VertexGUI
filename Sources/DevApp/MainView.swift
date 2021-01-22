import ExperimentalReactiveProperties
import SwiftGUI 
import GfxMath

public class MainView: SingleChildWidget {
  @ExperimentalReactiveProperties.MutableProperty
  private var items = [0]

  override public func buildChild() -> Widget {
    Experimental.SimpleColumn { [unowned self] in
      Button {
        Text("add item")
      } onClick: { _ in
        items.append(items.last! + 1)
      }

      Experimental.List($items) {
        Experimental.Text(styleProperties: {
          ($0.textColor, Color.white)
        }, String($0))
      }
    }
  }
}