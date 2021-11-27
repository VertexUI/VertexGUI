import VertexGUI
import Swim
import OpenCombine

public class MainView: ComposedWidget, SlotAcceptingWidgetProtocol {
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

  @Compose override public var content: ComposedContent {
    List(items: Array(repeating: "Test", count: 50)).withContent {
      List<String>.itemSlot {
        Text($0).with(classes: "list-item")
      }
    }.with(styleProperties: {
      (\.$height, .rh(100))
      (\.$overflowY, .scroll)
    })
  }

  override public var style: Style? {
    Style("&") {} nested: {
      Style(".list-item") {
        (\.$foreground, .black)
      }

      Style(".list-item:hover") {
        (\.$background, .grey)
      }

      FlatTheme(primaryColor: .orange, secondaryColor: .blue, backgroundColor: Color(10, 30, 50, 255)).styles
    }
  }
}
