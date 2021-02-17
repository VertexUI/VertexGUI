import SwiftGUI 
import ExperimentalReactiveProperties

public class MainView: Experimental.ComposedWidget {
  @ExperimentalReactiveProperties.MutableProperty
  private var counter = 0

  override public func performBuild() {
    rootChild = Experimental.Container(styleProperties: { _ in
      (SimpleLinearLayout.ParentKeys.alignContent, SimpleLinearLayout.Align.center)
      (SimpleLinearLayout.ParentKeys.justifyContent, SimpleLinearLayout.Justify.center)
    }) { [unowned self] in

      Experimental.Button {
        
        Experimental.Text(ExperimentalReactiveProperties.ComputedProperty(compute: {
          "counter: \(counter)"
        }, dependencies: [$counter]))
      } onClick: {
        counter += 1
      }

      Experimental.DefaultTheme()
    }
  }
}