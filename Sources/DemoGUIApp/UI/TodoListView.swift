import WidgetGUI

public class TodoListView: SingleChildWidget {
  @Inject private var store: TodoStore
  private var listId: String
  private var list: TodoList {
    store.state.lists.first {
      $0.id == listId
    }!
  }
  private var expandedItemIndices: Set<Int> = []

  public init(_ listId: String) {
    self.listId = listId
  }

  override public func buildChild() -> Widget {
    ScrollArea(scrollX: .Never) { [unowned self] in
      Column(spacing: 16) {
        Text(list.name, fontSize: 32, fontWeight: .Bold, color: list.color)

        Button {
          Text("Add Todo")
        } onClick: { [unowned self] _ in
          handleAddTodoClick()
        }

        ObservingBuilder(store.$state) {
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
    MouseArea {
      Padding(all: 16) {
        Column(spacing: 24) {
          Row(spacing: 48) {
            TaskCompletionButton(color: list.color)
            Row.Item(crossAlignment: .Center) {
              Text(todo.description, wrap: true)
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
    store.dispatch(.AddItem(TodoItem(description: "New Todo Item"), listId: list.id))
  }
}
