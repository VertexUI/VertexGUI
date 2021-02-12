import ExperimentalReactiveProperties
import SwiftGUI 

public class MainView: Experimental.ComposedWidget {

  @ExperimentalReactiveProperties.MutableProperty
  private var text: String = "initial Text"

  @ExperimentalReactiveProperties.MutableProperty
  var items: [String] = (0..<40).map { _ in "WOWO" }

  @ExperimentalReactiveProperties.MutableProperty
  var layoutDirection: SimpleLinearLayout.Direction = .row

  override public func performBuild() {
    rootChild = Experimental.SimpleColumn { [unowned self] in
      Experimental.DefaultTheme()

      /*Experimental.Button {
        Experimental.Text("WOWOWWOOW")
      }

      Experimental.TextInput(styleProperties: {
        ($0.borderWidth, BorderWidth(bottom: 2.0))
        ($0.borderColor, Color.yellow)
        ($0.padding, Insets(all: 8))
      }, mutableText: $text)

      Experimental.Text(styleProperties: {
        ($0.textColor, Color.white)
      }, $text)

      Experimental.Drawing { drawingContext in
        //drawingContext.clip(rect: DRect(min: .zero, max: DVec2(200, 200)))
        drawingContext.drawRect(rect: DRect(min: .zero, size: DSize2(200, 200)), paint: Paint(color: .red))
      }*/

      /*Experimental.ConstrainedSizeBox(styleProperties: {
        ($0.width, 300.0)
        ($0.height, 300.0)
      }) {
        
        Experimental.Container(styleProperties: {
          ($0.overflowY, Overflow.scroll)
          ($0.overflowX, Overflow.scroll)
        }) {

          Experimental.SimpleColumn() {

            Experimental.ConstrainedSizeBox(styleProperties: {
              ($0.width, 500)
              ($0.height, 500)
            }) {

              Experimental.Container(styleProperties: {
                ($0.padding, Insets(all: 128))
                ($0.background, Color.yellow)
              }) {

                Experimental.Button() {
                  Experimental.Text("add child content")
                }
              }
            }
          }
        }
      }*/

      //NestedWidget(NestedData(content: "level1", children: []))

      /*Experimental.Button {
        Experimental.Text("add item")
      } onClick: {
        items.append(items.last! + 1)
      }*/
      Experimental.Container(styleProperties: {
        ($0.layout, SimpleLinearLayout.self)
        (SimpleLinearLayout.ParentKeys.direction, $layoutDirection)
        //($0.padding, Insets(all: 128))
        ($0.width, 800.0)
        ($0.background, Color.blue)
      }) {
        Experimental.Style(".test-container") {
          ($0.background, Color.green)

          Experimental.Style("&:hover") {
            ($0.background, Color.red)
            (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.stretch)
          }
        }

        Experimental.Container(styleProperties: {
          ($0.padding, Insets(all: 43))
          ($0.background, Color.yellow)
        }) {
          Experimental.Text("CONTAINER TWO")
        }

        Experimental.Container(styleProperties: {
          ($0.background, Color.orange)
          (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.center)
        }) {
          Experimental.Text("CONTAINER THREE")
        }

        Experimental.Container(styleProperties: {
          ($0.background, Color.green)
          (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.end)
        }) {
          Experimental.Text("CONTAINER FOUR")
        }

        Experimental.Container(classes: ["test-container"], styleProperties: {
          ($0.padding, Insets(all: 16))
          (SimpleLinearLayout.ChildKeys.grow, 1.0)
        }) {
          Experimental.Text("WSOW")
        }
      }.onClick {
        layoutDirection = .column
      }

      /*Column {
        Experimental.List($items) { item in
          Experimental.Button {
            Experimental.Text(styleProperties: {
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

  class NestedWidget: Experimental.ComposedWidget {
    @ExperimentalReactiveProperties.MutableProperty
    var data: NestedData
    @ExperimentalReactiveProperties.ComputedProperty
    var childData: [NestedData]

    public init(_ data: NestedData) {
      self.data = data
      super.init()
      self._childData.reinit(compute: { [unowned self] in
        self.data.children
      }, dependencies: [$data])
    }

    override func performBuild() {
      rootChild = Experimental.Container(styleProperties: {
        ($0.padding, Insets(left: 16))
      }) { [unowned self] in
        Experimental.SimpleColumn {
          Experimental.Text(styleProperties: {
            ($0.textColor, Color.black)
          }, data.content)

          Experimental.Container(styleProperties: {
            ($0.padding, Insets(all: 32))
          }) {
            Experimental.Button() {
              Experimental.Text("add child content")
            }.onClick {
              data.children.append(NestedData(content: "child", children: []))
            }
          }

          Experimental.List($childData) {
            NestedWidget($0)
          }
        }
      }
    }

    override func renderContent() -> RenderObject? {
      print("Render Nested Widget", id)
      return super.renderContent()
    }
  }
}