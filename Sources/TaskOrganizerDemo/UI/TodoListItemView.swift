import SwiftGUI

public class TodoListItemView: ComposedWidget {
  @Inject
  private var experimentalStore: ExperimentalTodoStore

  private var item: TodoItem
  private var editable: Bool
  private var checkable: Bool

  @State
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
          experimentalStore.commit(.updateTodoItem(updatedItem: updatedItem))
        }
      }

      Text(item.description).with(classes: ["description"])
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

  override public var experimentalStyle: Experimental.Style {
    Experimental.Style("&") {
      (\.$foreground, .white)
      (\.$padding, Insets(top: 16, right: 24, bottom: 16, left: 24))
      (\.$borderColor, AppTheme.listItemDividerColor)
      (\.$borderWidth, BorderWidth(bottom: 1.0))
    } nested: {

      Experimental.Style(".description") {
        (\.$alignSelf, .center)
        (\.$padding, Insets(left: 32))
      }

      Experimental.Style(".completion-button") {
        (\.$foreground, AppTheme.primaryColor)
      } nested: {

        Experimental.Style("&:hover") {
          (\.$foreground, AppTheme.primaryColor.darkened(40))
        }
      }
    }
  }
}
