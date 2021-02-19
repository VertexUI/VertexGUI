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
  private var testSlot1 = SlotContent(slot: MainView.TestSlot1)

  override public func performBuild() {
    rootChild = Container(styleProperties: {
      (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
      ($0.background, Color.grey)
    }) { [unowned self] in
      TextInput(mutableText: $text1).with(styleProperties: {
        ($0.caretColor, Color.red)
      })

      DefaultTheme()

      //testSlot1()

      Text(someInjectedData)

      NestedWidget(NestedData(content: "level1", children: []))

      /*ReactiveContent($text1) {
        Text(text1)

        Button {
          Text("toggle flag")
        } onClick: {
          flag = true
        }
      
        ReactiveContent($flag) {
          if flag {
            Text($text2)
          }
        }
      }

      Container(classes: ["start"], styleProperties: {
        ($0.width, 600.0)
        ($0.height, 300.0)
        ($0.minWidth, 1000.0)
        (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
        ($0.background, Color.grey)
      }) {
        Container(classes: ["middle"], styleProperties: {
          ($0.width, .inherit)
          ($0.foreground, Color.white)
          //($0.maxWidth, 500.0)
          //($0.minHeight, 400.0)
          //($0.overflowX, Overflow.scroll)
          //($0.overflowY, Overflow.scroll)
          //(SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.stretch)
          ($0.background, Color.red)
          //(SimpleLinearLayout.ChildKeys.shrink, 1.0)
          //(SimpleLinearLayout.ChildKeys.grow, 1.0)
        }) {
          Text("NONE")
          /*List(classes: ["end"], styleProperties: {
            //(SimpleLinearLayout.ChildKeys.grow, 1.0)
            ($0.background, Color.green)
          }, StaticProperty([1, 2, 3, 4])) { _ in
            Text("This is a looong text")
          }*/
        }

        /*Container(styleProperties: {
          (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.stretch)
          ($0.maxHeight, 200.0)
          ($0.background, Color.blue)
        }) {
          Text("NONE 2")
        }*/
      }*/

      /*Container(styleProperties: {
        ($0.background, Color.grey)
        ($0.height, 200.0)
        (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
      }) {
        Container(styleProperties: {
          (SimpleLinearLayout.ChildKeys.shrink, 1.0)
          ($0.overflowY, Overflow.scroll)
          ($0.background, Color.yellow)
        }) {
          Container(styleProperties: {
            ($0.width, 500.0)
            ($0.height, 500.0)
            ($0.background, Color.green)
          }) {
            Text("WOW")
          }
        }
      }*/

      /*Container(styleProperties: {
        ($0.background, Color.blue)
        ($0.maxHeight, 100.0)
        ($0.width, 300.0)
      }) {
        Container(styleProperties: {
          ($0.minHeight, 200.0)
          ($0.background, Color.yellow)
        }) {
          Text("text")
        }
      }

      Text("NON REACTIVE TEXT")

      ReactiveContent($text) {
        Text(text)
      }

      Button {
        Text("Change the reactive text")
      }.onClick {
        text = "second reactive text"
      }*/

      /*
      /*Button {
        Text("WOWOWWOOW")
      }

      TextInput(styleProperties: {
        ($0.borderWidth, BorderWidth(bottom: 2.0))
        ($0.borderColor, Color.yellow)
        ($0.padding, Insets(all: 8))
      }, mutableText: $text)

      Text(styleProperties: {
        ($0.textColor, Color.white)
      }, $text)

      Drawing { drawingContext in
        //drawingContext.clip(rect: DRect(min: .zero, max: DVec2(200, 200)))
        drawingContext.drawRect(rect: DRect(min: .zero, size: DSize2(200, 200)), paint: Paint(color: .red))
      }*/

        
      Container(styleProperties: {
        ($0.overflowY, Overflow.scroll)
        ($0.overflowX, Overflow.scroll)
        ($0.width, 300.0)
      }) {
        Container(styleProperties: {
          ($0.padding, Insets(all: 128))
          ($0.width, 600.0)
          ($0.background, Color.yellow)
        }) {


          Button() {
            Text("add child content")
          }
        }
      }

      /*Button {
        Text("add item")
      } onClick: {
        items.append(items.last! + 1)
      }*/
      Container {
      Container(styleProperties: {
        ($0.layout, SimpleLinearLayout.self)
        (SimpleLinearLayout.ParentKeys.direction, $layoutDirection)
        //($0.padding, Insets(all: 128))
        ($0.width, 800.0)
        ($0.height, 1000.0)
        ($0.background, Color.blue)
      }) {
        Style(".test-container") {
          ($0.background, Color.green)

          Style("&:hover") {
            ($0.background, Color.red)
            (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.stretch)
          }
        }

        Container(styleProperties: {
          ($0.padding, Insets(all: 43))
          ($0.background, Color.yellow)
        }) {
          Text("CONTAINER TWO")
        }

        Container(styleProperties: {
          ($0.background, Color.orange)
          (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.center)
        }) {
          Text("CONTAINER THREE")
        }

        Container(styleProperties: {
          ($0.background, Color.green)
          (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.end)
        }) {
          Text("CONTAINER FOUR")
        }

        Container(classes: ["test-container"], styleProperties: {
          ($0.padding, Insets(all: 16))
          (SimpleLinearLayout.ChildKeys.grow, 1.0)
        }) {
          Text("WSOW")
        }
      }.onClick {
        layoutDirection = .column
      }
      }*/

      /*Column {
        List($items) { item in
          Button {
            Text(styleProperties: {
              ($0.textColor, Color.white)
            }, String(item))
          }
        }
      }*/
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
      rootChild = Container(styleProperties: {
        ($0.padding, Insets(left: 16))
      }) { [unowned self] in
        Text(styleProperties: {
          ($0.foreground, Color.black)
        }, data.content)

        Container(styleProperties: {
          ($0.padding, Insets(all: 32))
        }) {
          Button() {
            Text("add child content")
          }.onClick {
            data.children.append(NestedData(content: "child", children: []))
          }
        }

        List($childData) {
          NestedWidget($0)
        }
      }
    }

    override func renderContent() -> RenderObject? {
      print("Render Nested Widget", id)
      return super.renderContent()
    }
  }
}