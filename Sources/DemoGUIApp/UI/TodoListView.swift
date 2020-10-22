import WidgetGUI

public class TodoListView: SingleChildWidget {
  @Inject private var store: TodoStore
  @ObservableProperty private var list: TodoList

  private var expandedItemIndices: Set<Int> = []
  @MutableProperty
  private var nameEditMode: Bool = false
  private var updatedNameBuffer: String = ""
  @MutableProperty
  private var editingItemIndex: Int? = nil
  private var updatedItemDescription: String = ""


  public init(_ observableList: ObservableProperty<TodoList>) {
    self._list = observableList
  }

  override public func buildChild() -> Widget {
    ScrollArea(scrollX: .Never) { [unowned self] in
      Column(spacing: 16) {
        ObservingBuilder($nameEditMode) {
          if nameEditMode {
            Row(spacing: 16) {
              TextField(list.name).onTextChanged.chain {
                updatedNameBuffer = $0
              }.requestFocus()

              Button {
                Text("done")
              } onClick: { _ in
                store.dispatch(.UpdateListName(updatedNameBuffer, listId: list.id))
                nameEditMode = false
                updatedNameBuffer = list.name
              }
            }
          } else {
            MouseArea {
              Text(list.name, fontSize: 32, fontWeight: .Bold, color: list.color)
            } onClick: { _ in
              nameEditMode = true
            }
          }
        }

        Button {
          Text("Add Todo")
        } onClick: { [unowned self] _ in
          handleAddTodoClick()
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
    MouseArea { [unowned self] in
      Padding(all: 16) {
        Column(spacing: 24) {
          Row(spacing: 48) {
            Row.Item(crossAlignment: .Center) {
              TaskCompletionButton(StaticProperty(todo.completed), color: list.color) { _ in
                var updatedItem = todo
                updatedItem.completed = !updatedItem.completed
                store.dispatch(.UpdateTodoItem(updatedItem, index: index, listId: list.id))
              }
            }

            Row.Item(crossAlignment: .Center) {
              ObservingBuilder($editingItemIndex) {
                if editingItemIndex == index {
                  Row(spacing: 16) {
                    TextField(todo.description).onTextChanged.chain {
                      updatedItemDescription = $0
                    }.requestFocus().onFocusChanged.chain { focused in
                      if !focused {
                        if editingItemIndex == index {
                          //editingItemIndex = nil
                          print("WOULD SET NIL")
                        }
                      }
                    }

                    Button {
                      Text("done")
                    } onClick: { _ in
                      store.dispatch(.UpdateTodoDescription(updatedItemDescription, index: index, listId: list.id))
                      editingItemIndex = nil
                    }
                  }
                } else {
                  MouseArea {
                    Text(todo.description, wrap: true)
                  } onClick: { _ in
                    editingItemIndex = index
                    updatedItemDescription = todo.description
                  }
                }
              }
            }
          }

          if expandedItemIndices.contains(index) {
            Row {
              todo.images.map {
                ImageView(image: $0)
              }
            }
          }
        }
      }
    } onClick: { [unowned self] _ in
      if todo.images.count > 0 {
        withChildInvalidation {
          expandedItemIndices.insert(index)
        }
      }
    }

    Column.Item(crossAlignment: .Stretch) {
      Padding(left: 40 + 48) {
        Divider(color: .Grey, axis: .Horizontal, thickness: 1)
      }
    }
  }

  private func handleAddTodoClick() {
    store.dispatch(.AddItem(listId: list.id))
  }
}
