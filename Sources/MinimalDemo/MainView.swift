import SwiftGUI 
import ReactiveProperties

public class MainView: ComposedWidget {
  @MutableProperty
  private var counter = 0

  override public func performBuild() {
    rootChild = Container(styleProperties: { _ in
      (SimpleLinearLayout.ParentKeys.alignContent, SimpleLinearLayout.Align.center)
      (SimpleLinearLayout.ParentKeys.justifyContent, SimpleLinearLayout.Justify.center)
    }) { [unowned self] in

      Button {
        
        Text(ComputedProperty(compute: {
          "counter: \(counter)"
        }, dependencies: [$counter]))
      } onClick: {
        counter += 1
      }

      DefaultTheme()
    }
  }
}