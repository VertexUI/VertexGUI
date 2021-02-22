import ReactiveProperties
import SwiftGUI 

public class MainView: ComposedWidget, SlotAcceptingWidget {
  @Inject
  var someInjectedData: String

  @MutableProperty
  private var flag: Bool = false
  @MutableProperty
  private var text1: String = "initial reactive Text 1"
  @MutableProperty
  private var text2: String = "initial reactive Text 2"

  @MutableProperty
  var items: [String] = (0..<40).map { _ in "WOWO" }

  @MutableProperty
  var layoutDirection: SimpleLinearLayout.Direction = .row

  static let TestSlot1 = Slot(key: "testSlot1", data: Void.self)
  private var testSlot1 = SlotContentManager(MainView.TestSlot1)

  override public func performBuild() {
    rootChild = Container().with(styleProperties: {
      (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
      ($0.background, Color.grey)
    }).withContent { [unowned self] in
      Container().with(styleProperties: {
        ($0.width, 200.0)
        ($0.height, 200.0)
        ($0.background, Color.red)
        (SimpleLinearLayout.ChildKeys.margin, Insets(top: 8, right: 16, bottom: 32, left: 64))
      }).withContent {
        Space(.zero)
      }

      Container().with(styleProperties: {
        ($0.width, 180.0)
        ($0.height, 180.0)
        ($0.background, Color.yellow)
        (SimpleLinearLayout.ChildKeys.margin, Insets(all: 16))
      }).withContent {
        Space(.zero)
      }

      TestWidget()
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
          Button() {
            Text("add child content")
          }.onClick {
            data.children.append(NestedData(content: "child", children: []))
          }
        }

        /*List($childData).withContent {
          $0.itemSlot {
            NestedWidget($0)
          }
        }*/
      }
    }

    override func renderContent() -> RenderObject? {
      print("Render Nested Widget", id)
      return super.renderContent()
    }
  }
}