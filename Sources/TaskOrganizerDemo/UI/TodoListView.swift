import SwiftGUI
import ReactiveProperties
import CXShim

public class TodoListView: ContentfulWidget {
  @Inject
  private var store: TodoStore
  @Inject
  private var experimentalStore: ExperimentalTodoStore

  @ImmutableBinding
  private var listId: Int

  @State
  private var list: TodoList?

  var listIdSubscription: AnyCancellable?

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


  public init(listId immutableListId: Experimental.ImmutableBinding<Int>, editable: Bool = true, checkable: Bool = true) {
    self._listId = immutableListId
    self.editable = editable
    self.checkable = checkable
    super.init()

    _ = onDependenciesInjected { [unowned self] in
      listIdSubscription = $listId.sink { newListId in
        list = experimentalStore.state.lists.first { $0.id == newListId }
      }
    }
  }

  @ExpDirectContentBuilder override public var content: ExpDirectContent {
    Container().experimentalWith(styleProperties: {
      (\.$direction, .column)
    }).withContent { [unowned self] in

      Container().with(classes: ["header"]).withContent {

        Text(list?.name ?? "").with(classes: ["list-name"])

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

      List(items: Experimental.ImmutableBinding($list.immutable, get: { $0?.items ?? [] })).with(classes: ["todo-item-list"]).withContent {
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
    store.commit(.AddItem(listId: list!.id))
  }
}
