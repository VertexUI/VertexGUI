import SwiftGUI 
import ReactiveProperties

public class MainView: ComposedWidget {
  @MutableProperty
  private var counter = 0

  override public func performBuild() {
    rootChild = Container().with(styleProperties: { _ in
      (SimpleLinearLayout.ParentKeys.alignContent, SimpleLinearLayout.Align.center)
      (SimpleLinearLayout.ParentKeys.justifyContent, SimpleLinearLayout.Justify.center)
    }).withContent { [unowned self] in

      Button().withContent {
        
        Text(ComputedProperty(compute: {
          "counter: \(counter)"
        }, dependencies: [$counter]))
      }.onClick {
        counter += 1
      }
    }
  }

  override public var style: Style {
    Style("&") {
      FlatTheme(primaryColor: .blue, secondaryColor: .green, backgroundColor: Color(10, 20, 50, 255)).styles
    }
  }
}