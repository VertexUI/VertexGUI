import ReactiveProperties
import SwiftGUI 

public class MainView: ContentfulWidget, SlotAcceptingWidgetProtocol {
  @Inject
  var someInjectedData: String

  @MutableProperty
  private var flag: Bool = false
  @MutableProperty
  private var text1: String = "initial reactive Text 1"
  @MutableProperty
  private var text2: String = "initial reactive Text 2"

  @MutableProperty
  var items: [String] = []

  @MutableProperty
  var layoutDirection: SimpleLinearLayout.Direction = .row

  @State
  var myState: String = "This is a value from an @State property."

  static let TestSlot1 = Slot(key: "testSlot1", data: Void.self)
  private var testSlot1 = SlotContentManager(MainView.TestSlot1)

  override public init() {
    super.init()
    let test =  Experimental.Style([StyleSelectorPart(type: TextInput.self)], TextInput.self) {
        (\.$caretColor, .white)
      }
  }

  @ExpDirectContentBuilder override public var content: ExpDirectContent {
    Container().with(styleProperties: {
      (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
      ($0.background, Color.grey)
    }).withContent { [unowned self] in
      Button().withContent {
        Text("ADD")
      }.onClick {
        items.append("NEW ITEM")
        myState = "The @State property changed!"
      }

      Text(myState).experimentalWith(styleProperties: {
        (\.$background, .black)
      })

      TestWidget(boundText: $myState.immutable)

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
      }
    }
  }

  override public var style: Style? {
    Style("&") {
      Style("&< .container") {
        ($0.background, Color.blue)
      }
    }
  }

  override public var experimentalStyle: Experimental.Style? {
    Experimental.Style("&") {
      (\.$background, Color.yellow)
      (\.$foreground, .white)
    } nested: {
      FlatTheme(primaryColor: .orange, secondaryColor: .blue, backgroundColor: Color(10, 30, 50, 255)).experimentalStyles
    }
  }

  struct NestedData: Equatable {
    var content: String
    var children: [NestedData]
  }

  class NestedWidget: ComposedWidget {
    @MutableProperty
    var data: NestedData
    @ComputedProperty
    var childData: [NestedData]

    public init(_ data: NestedData) {
      self.data = data
      super.init()
      self._childData.reinit(compute: { [unowned self] in
        self.data.children
      }, dependencies: [$data])
    }

    override func performBuild() {
      rootChild = Container().with(styleProperties: {
        ($0.padding, Insets(left: 16))
      }).withContent { [unowned self] in
        Text(styleProperties: {
          ($0.foreground, Color.black)
        }, data.content)

        Container().with(styleProperties: {
          ($0.padding, Insets(all: 32))
        }).withContent {
          Button().withContent {
            Text("add child content")
          }.onClick {
            data.children.append(NestedData(content: "child", children: []))
          }
        }

        List($childData).withContent {
          $0.itemSlot {
            NestedWidget($0)
          }
        }
      }
    }
  }
}