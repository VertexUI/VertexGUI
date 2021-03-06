import SwiftGUI
import CXShim

public class MainView: ContentfulWidget, SlotAcceptingWidgetProtocol {
  @Inject
  var someInjectedData: String

  @State
  var myState: String = "This is a value from an @State property."
  @State
  var testBackgroundColor: Color = .orange

  static let TestSlot1 = Slot(key: "testSlot1", data: Void.self)
  private var testSlot1 = SlotContentManager(MainView.TestSlot1)

  var stateSubscription: AnyCancellable?

  override public init() {
    super.init()
    stateSubscription = self.$myState.sink {
      print("MY STATEA CHANGED", $0)
    }
  }

  @ExpDirectContentBuilder override public var content: ExpDirectContent {
    Container().experimentalWith(styleProperties: {
      (\.$background, .red)
    }).withContent { [unowned self] in
   

      TestWidget(boundText: $myState.mutable)

      Container().experimentalWith(styleProperties: {
        (\.$width, 200)
        (\.$height, 150)
        (\.$background, .black)
      })

      Container().experimentalWith(styleProperties: {
        (\.$background, .white)
        (\.$width, 150)
        (\.$maxHeight, 120)
        (\.$alignSelf, .stretch)
      })

      Container().experimentalWith(styleProperties: {
        (\.$background, .blue)
        (\.$minWidth, 10)
        (\.$minHeight, 10)
        (\.$padding, Insets(all: 128))
        (\.$maxHeight, 30)
      })

      Container().experimentalWith(styleProperties: {
        (\.$background, .orange)
        (\.$maxWidth, 200)
        (\.$minHeight, 40)
        (\.$grow, 1)
      })

      Container().experimentalWith(styleProperties: {
        (\.$background, .white)
        (\.$minHeight, 120)
        (\.$minWidth, 10)
        (\.$padding, Insets(all: 128))
        (\.$shrink, 1)
      })



      /*Container().experimentalWith(styleProperties: {
        (\.$background, .blue)
        (\.$padding, Insets(all: 32))
        (\.$grow, 1)
      })

      Container().experimentalWith(styleProperties: {
        (\.$background, .yellow)
        (\.$padding, Insets(all: 32))
        (\.$grow, $testGrow.immutable)
      })

      Container().with(classes: ["container-3"])*/

      /*Button().withContent {
        Text("ADD")
      }.onClick {
        items.append("NEW ITEM")
        myState = "The @State property changed!"
        testBackgroundColor = .white
      }

      /*Text(myState).experimentalWith(styleProperties: {
        (\.$background, .black)
      })*/

      TestWidget(boundText: $myState.immutable).experimentalWith(styleProperties: {
        (\.$background, $testBackgroundColor.immutable)
      })

      TextInput(mutableText: $text1)

      Container().with(styleProperties: {
        ($0.overflowY, Overflow.scroll)
        (SimpleLinearLayout.ChildKeys.shrink, 1.0)
      }).withContent {
        List($items).withContent {
          $0.itemSlot { item in
            Container().with(styleProperties: {
              ($0.padding, 32.0)
            }).withContent {
              Text(item).with()
            }
          }
        }.experimentalWith(styleProperties: {
          (\.$background, Color.lightBlue)
          (\.$shrink, 1)
        })
      }*/
    }
  }

  override public var experimentalStyle: Experimental.Style? {
    Experimental.Style("&") {} nested: {
      Experimental.Style(".container-3") {
        (\.$padding, Insets(all: 32))
        (\.$background, .white)
        (\.$grow, 1)
      }

      FlatTheme(primaryColor: .orange, secondaryColor: .blue, backgroundColor: Color(10, 30, 50, 255)).experimentalStyles
    }
  }
}