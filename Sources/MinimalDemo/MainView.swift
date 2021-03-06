import SwiftGUI 
import ReactiveProperties

public class MainView: ContentfulWidget {
  @MutableProperty
  private var counter = 0

  @ExpDirectContentBuilder override public var content: ExpDirectContent {
    Container().experimentalWith(styleProperties: {
      (\.$alignContent, .center)
      (\.$justifyContent, .center)
    }).withContent { [unowned self] in

      Button().onClick {
        counter += 1
      }.withContent {
        Text(ComputedProperty(compute: {
          "counter: \(counter)"
        }, dependencies: [$counter]))
      }
    }
  }

  override public var experimentalStyle: Experimental.Style {
    Experimental.Style("&") {} nested: {
      FlatTheme(primaryColor: .blue, secondaryColor: .green, backgroundColor: Color(10, 20, 50, 255)).experimentalStyles
    }
  }
}