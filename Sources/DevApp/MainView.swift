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

  static let TestSlot1 = Slot(key: "testSlot1", data: Void.self)
  private var testSlot1 = SlotContentManager(MainView.TestSlot1)

  override public init() {
    super.init()
  }

  @ExpDirectContentBuilder override public var content: ExpDirectContent {
    Container().with(styleProperties: {
      (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
      ($0.background, Color.grey)
    }).withContent { [unowned self] in
      Button().with(styleProperties: {
        ($0.padding, 32)
      }).withContent {
        Text("ADD")
      }.onClick {
        items.append("NEW ITEM")
      }

      /*Container().with(styleProperties: {
        ($0.overflowY, Overflow.scroll)
        (SimpleLinearLayout.ChildKeys.shrink, 1.0)
      }).withContent {
        List($items).with(styleProperties: {
          ($0.background, Color.lightBlue)
        }).withContent {
          $0.itemSlot { item in
            Container().with(styleProperties: {
              ($0.padding, 32.0)
            }).withContent {
              Text(item).with()
            }
          }
        }
      }*/
    }
  }

  override public var style: Style? {
    Style("&") {
      Style("&< .container") {
        ($0.background, Color.blue)
      }
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