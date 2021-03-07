import SwiftGUI 

public class MainView: ContentfulWidget {
  @State
  private var counter = 0

  @ExpDirectContentBuilder override public var content: ExpDirectContent {
    Container().experimentalWith(styleProperties: {
      (\.$alignContent, .center)
      (\.$justifyContent, .center)
    }).withContent { [unowned self] in

      Button().onClick {
        counter += 1
      }.withContent {
        Text(Experimental.ImmutableBinding($counter.immutable, get: { "counter: \($0)" }))
      }
    }
  }

  override public var experimentalStyle: Experimental.Style {
    Experimental.Style("&") {} nested: {
      FlatTheme(primaryColor: .lightBlue, secondaryColor: .green, backgroundColor: Color(10, 20, 50, 255)).experimentalStyles
    }
  }
}