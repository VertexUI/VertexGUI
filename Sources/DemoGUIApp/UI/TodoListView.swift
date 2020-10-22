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
    TodoListItemView(todo, editable: true) { [unowned self] in
      store.dispatch(.UpdateTodoItem($0, index: index, listId: list.id))
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
