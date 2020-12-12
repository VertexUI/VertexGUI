import SwiftGUI

public class TodoListItemView: SingleChildWidget {
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
  }

  override public func buildChild() -> Widget {
    MouseArea { [unowned self] in
      Padding(all: 16) {
        Row(spacing: 48) {
          Row.Item(crossAlignment: .Center) {
            TaskCompletionButton(StaticProperty(item.completed), color: .Yellow) { _ in
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

                      _ = onDestroy(textField.onFocusChanged { focused in
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

                  Button {
                    Text("done")
                  } onClick: { _ in
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
    }
  }
}
