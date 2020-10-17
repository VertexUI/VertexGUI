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
    print("INIT TODOLISTVIEW")
  }

  override public func buildChild() -> Widget {
    ScrollArea(scrollX: .Never) { [unowned self] in
      Column(spacing: 16) {
        ObservingBuilder($nameEditMode) {
          if nameEditMode {
            Row {
              TextField(list.name).onTextChanged.chain {
                updatedNameBuffer = $0
              }

              Button {
                Text("done")
              } onClick: { _ in
                store.dispatch(.UpdateListName(updatedNameBuffer, listId: list.id))
                nameEditMode = false
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
            TaskCompletionButton(color: list.color)
            Row.Item(crossAlignment: .Center) {
              ObservingBuilder($editingItemIndex) {
                if editingItemIndex == index {
                  Row {
                    TextField(todo.description).onTextChanged.chain {
                      updatedItemDescription = $0
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
