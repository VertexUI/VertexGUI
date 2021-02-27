import SwiftGUI
import ReactiveProperties

public class TodoListView: ContentfulWidget {
  @Inject
  private var store: TodoStore

  @ObservableProperty
  private var listId: Int
  @ComputedProperty
  private var list: TodoList
  @MutableProperty
  private var editable: Bool
  private var checkable: Bool
  private var expandedItemIndices: Set<Int> = []

  @MutableProperty
  private var nameEditMode: Bool = false
  private var updatedNameBuffer: String = ""

  @MutableProperty
  private var editingItemIndex: Int? = nil
  private var updatedItemDescription: String = ""


  public init<P: ReactiveProperty>(listId listIdProperty: P, editable: Bool = true, checkable: Bool = true) where P.Value == Int {
    self.editable = editable
    self.checkable = checkable
    super.init()
    let binding = self.$listId.bind(listIdProperty)
    _ = onDependenciesInjected { [unowned self] in
      self.$list.reinit(compute: { [unowned self] in
        store.state.lists.first { $0.id == listId }!
      }, dependencies: [$listId, store.$state])
    }
    _ = onDestroy { [unowned binding] in
      binding.destroy()
    }
  }

  @ExpDirectContentBuilder override public var content: ExpDirectContent {
    Container().experimentalWith(styleProperties: {
      (\.$direction, .column)
    }).withContent { [unowned self] in

      Container().with(classes: ["header"]).withContent {

        Text(list.name).with(classes: ["list-name"])

        Space(DSize2(24, 0))

        Dynamic($editable) {
          if editable {
            Button().withContent {
              Text("add todo")
            }.onClick {
              handleAddTodoClick()
            }
          }
        }
      }

      Space(DSize2(0, 48))

      List(ComputedProperty<[TodoItem]>(compute: {
        list.items
      }, dependencies: [$list])).with(classes: ["todo-item-list"]).withContent {
        $0.itemSlot {
          build(todo: $0)
        }
      }
    }
  }

  func build(todo: TodoItem) -> Widget {
    TodoListItemView(todo, editable: editable, checkable: checkable)
  }

  override public var experimentalStyle: Experimental.Style {
    Experimental.Style("&") {} nested: {
      Experimental.Style(".header", Container.self) {
        (\.$alignContent, .center)
      }

      Experimental.Style(".list-name") {
        (\.$foreground, .white)
        (\.$fontWeight, .bold)
        (\.$fontSize, 36)
      }

      Experimental.Style(".todo-item-list") {
        (\.$alignSelf, .stretch)
        (\.$shrink, 1)
        (\.$overflowY, .scroll)
      }
    }
  }

  private func handleAddTodoClick() {
    store.commit(.AddItem(listId: list.id))
  }
}
