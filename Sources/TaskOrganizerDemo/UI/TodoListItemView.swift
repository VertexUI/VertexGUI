import SwiftGUI

public class TodoListItemView: ComposedWidget {
  @Inject
  private var store: TodoStore
  private var item: TodoItem
  private var editable: Bool
  private var checkable: Bool
  @MutableProperty
  private var editing: Bool = false
  private var updatedDescriptionBuffer: String = ""

  public init(_ item: TodoItem, editable: Bool = false, checkable: Bool = true) {
    self.item = item
    self.editable = editable
    self.checkable = checkable
    super.init()
  }

  override public func performBuild() {
    rootChild = Container().withContent { [unowned self] in
      TaskCompletionButton(item.completed).with(classes: ["completion-button"], styleProperties: { _ in
        (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.center)
      }).onClick {
        if checkable {
          var updatedItem = item
          updatedItem.completed = !updatedItem.completed
          store.dispatch(.UpdateTodoItem(updatedItem))
        }
      }

      Text(styleProperties: {
        (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.center)
        ($0.padding, Insets(left: 32))
      }, item.description)
    }
    /*MouseArea { [unowned self] in
      Padding(all: 16) {
        Row(spacing: 48) {
          Row.Item(crossAlignment: .Center) {
            TaskCompletionButton(StaticProperty(item.completed), color: .yellow) { _ in
              if checkable {
                var updatedItem = item
                updatedItem.completed = !updatedItem.completed
                store.dispatch(.UpdateTodoItem(updatedItem))
              }
            }
          }

          Row.Item(crossAlignment: .Center) {
            ObservingBuilder($editing) {
              if editing {
                Row(spacing: 16) {
                  Row.Item {
                    {
                      let textField = TextField(item.description)
                      
                      _ = onDestroy(textField.$text.onChanged {
                        updatedDescriptionBuffer = $0.new
                      })

                      _ = onDestroy(textField.onFocusChanged.addHandler { focused in
                        if !focused {
                          editing = false
                        }
                      })

                      _ = textField.onMounted.once {
                        textField.requestFocus()
                      }

                      return textField
                    }()
                  }

                  Button().withContent {
                    Text("done")
                  } onClick: {
                    var updatedItem = item
                    updatedItem.description = updatedDescriptionBuffer
                    editing = false
                    store.dispatch(.UpdateTodoItem(updatedItem))
                  }
                }
              } else {
                MouseArea {
                  Text(item.description, wrap: true)
                } onClick: { _ in
                  if editable {
                    editing = true
                    updatedDescriptionBuffer = item.description
                  }
                }
              }
            }
          }
        }
      }
    }*/
  }

  override public var style: Style {
    Style("&") {
      ($0.foreground, Color.white)
      ($0.padding, Insets(all: 32))
      ($0.borderColor, Color.white)
      ($0.borderWidth, BorderWidth(bottom: 1.0))

      Style(".completion-button") {
        ($0.foreground, AppTheme.primaryColor)
        
        Style("&:hover") {
          ($0.foreground, AppTheme.primaryColor.darkened(40))
        }
      }
    }
  }
}
