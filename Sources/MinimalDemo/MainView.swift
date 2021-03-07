import SwiftGUI 

public class MainView: ContentfulWidget {
  @State
  private var counter = 0

  @DirectContentBuilder override public var content: DirectContent {
    Container().with(styleProperties: {
      (\.$alignContent, .center)
      (\.$justifyContent, .center)
    }).withContent { [unowned self] in

      Button().onClick {
        counter += 1
      }.withContent {
        Text(ImmutableBinding($counter.immutable, get: { "counter: \($0)" }))
      }
    }
  }

  override public var style: Style {
    Style("&") {} nested: {
      FlatTheme(primaryColor: .lightBlue, secondaryColor: .green, backgroundColor: Color(10, 20, 50, 255)).styles
    }
  }
}