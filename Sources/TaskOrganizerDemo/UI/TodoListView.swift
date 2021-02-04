import SwiftGUI

public class TodoListView: SingleChildWidget {
  @Inject private var store: TodoStore
  @ObservableProperty private var list: TodoListProtocol
  private var editable: Bool
  private var checkable: Bool
  private var expandedItemIndices: Set<Int> = []
  @MutableProperty
  private var nameEditMode: Bool = false
  private var updatedNameBuffer: String = ""
  @MutableProperty
  private var editingItemIndex: Int? = nil
  private var updatedItemDescription: String = ""


  public init(_ observableList: ObservableProperty<TodoListProtocol>, editable: Bool = true, checkable: Bool = true) {
    self._list = observableList
    self.editable = editable
    self.checkable = checkable
  }

  override public func buildChild() -> Widget {
    ScrollArea(scrollX: .Never) { [unowned self] in
      Column(spacing: 16) {
        ObservingBuilder($nameEditMode) {
          if nameEditMode {
            Row(spacing: 16) {
              {
                let textField = TextField(list.name)
                _ = onDestroy(textField.$text.onChanged {
                  updatedNameBuffer = $0.new
                })

                _ = onDestroy(onFocusChanged.addHandler { [unowned self] in
                  if !$0 {
                    nameEditMode = false
                  }
                })
                
                _ = textField.onMounted.once {
                  textField.requestFocus()
                }

                return textField
              }()

              Button {
                Text("done")
              } onClick: { _ in
                store.commit(.UpdateListName(updatedNameBuffer, listId: list.id))
                nameEditMode = false
                updatedNameBuffer = list.name
              }
            }
          } else {
            MouseArea {
              Text(list.name, fontSize: 32, fontWeight: .bold, color: list.color)
            } onClick: { _ in
              nameEditMode = editable && true
            }
          }
        }

        if editable {
          Button {
            Text("Add Todo")
          } onClick: { [unowned self] _ in
            handleAddTodoClick()
          }
        }

        ObservingBuilder($list) {
          Column {
            list.items.enumerated().map { (index, todo) in
              build(todo: todo, index: index)
            }
          }
        }
      }
    }
  }

  @Flex.ItemBuilder private func build(todo: TodoItem, index: Int) -> [Flex.Item] {
    TodoListItemView(todo, editable: editable, checkable: checkable)

    Column.Item(crossAlignment: .Stretch) {
      Padding(left: 40 + 48) {
        Divider(color: .grey, axis: .Horizontal, thickness: 1)
      }
    }
  }

  private func handleAddTodoClick() {
    store.commit(.AddItem(listId: list.id))
  }
}
