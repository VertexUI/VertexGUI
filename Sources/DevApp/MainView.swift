import VertexGUI
import Swim
import OpenCombine

public class MainView: ContentfulWidget, SlotAcceptingWidgetProtocol {
  @Inject
  var someInjectedData: String

  @State
  var myState: String = "This is a value from an @State property."
  @State
  var testBackgroundColor: VertexGUI.Color = .orange
  @State
  var testImage: Swim.Image<RGBA, UInt8>
  @State
  var textVisibility: Visibility = .hidden

  static let TestSlot1 = Slot(key: "testSlot1", data: Void.self)
  private let testSlot1 = SlotContentManager(MainView.TestSlot1)

  var stateSubscription: AnyCancellable?

  override public init() {
    self.testImage = Swim.Image(width: 800, height: 600, color: Swim.Color(r: 0, g: 0, b: 0, a: 255))
    super.init()
    stateSubscription = self.$myState.publisher.sink {
      print("MY STATEA CHANGED", $0)
    }
  }

  @DirectContentBuilder override public var content: DirectContent {
    Container().withContent {
      Text("TEST").with(styleProperties: {
        (\.$visibility, $textVisibility.immutable)
        (\.$foreground, .black)
      })

      Button().onClick { [unowned self] in
        textVisibility = .visible
      }
    }
  }

  override public var style: Style? {
    Style("&") {} nested: {
      Style(".container-3") {
        (\.$padding, Insets(all: 32))
        (\.$background, .white)
        (\.$grow, 1)
      }

      FlatTheme(primaryColor: .orange, secondaryColor: .blue, backgroundColor: Color(10, 30, 50, 255)).styles
    }
  }
}
