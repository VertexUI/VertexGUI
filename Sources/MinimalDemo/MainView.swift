import VertexGUI 

public class MainView: ComposedWidget {
  @State
  private var counter = 0

  @DirectContentBuilder override public var content: DirectContent {
    Container().with(classes: ["container"]).withContent { [unowned self] in
      Button().onClick {
        counter += 1
      }.withContent {
        Text(ImmutableBinding($counter.immutable, get: { "counter: \($0)" }))
      }
    }
  }

  override public var style: Style {
    let primaryColor = Color(77, 255, 154, 255)

    return Style("&") {
      (\.$background, Color(10, 20, 30, 255))
    } nested: {

      Style(".container", Container.self) {
        (\.$alignContent, .center)
        (\.$justifyContent, .center)
      }

      Style("Button") {
        (\.$padding, Insets(all: 16))
        (\.$background, primaryColor)
        (\.$foreground, .black)
        (\.$fontWeight, .bold)
      } nested: {
        
        Style("&:hover") {
          (\.$background, primaryColor.darkened(20))
        }

        Style("&:active") {
          (\.$background, primaryColor.darkened(40))
        }
      }
    }
  }
}