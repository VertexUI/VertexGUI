import SwiftGUI
import ReactiveProperties
import CXShim

public class TodoListView: ContentfulWidget {
  @Inject private var store: TodoStore
  @Inject private var experimentalStore: ExperimentalTodoStore

  @ImmutableBinding private var listId: Int

  @State private var list: TodoList?

  var listIdSubscription: AnyCancellable?
  var storeListsSubscription: AnyCancellable?

  @State private var editable: Bool
  private var checkable: Bool

  @State private var editingName: Bool = false
  @State private var updatedNameBuffer: String = ""

  @State private var editingItemIndex: Int? = nil
  private var updatedItemDescription: String = ""

  public init(listId immutableListId: Experimental.ImmutableBinding<Int>, editable: Bool = true, checkable: Bool = true) {
    self._listId = immutableListId
    self.editable = editable
    self.checkable = checkable
    super.init()

    _ = onDependenciesInjected { [unowned self] in
      listIdSubscription = $listId.sink { _ in
        resolveList()
      }

      storeListsSubscription = experimentalStore.$state.lists.sink { _ in
        resolveList()
      }
    }
  }

  func resolveList() {
    list = experimentalStore.state.lists.first { $0.id == listId }
  }

  @ExpDirectContentBuilder override public var content: ExpDirectContent {
    Container().experimentalWith(styleProperties: {
      (\.$direction, .column)
    }).withContent { [unowned self] in

      Container().with(classes: ["header"]).withContent {
        
        Dynamic($editingName) {
          if editingName {
            TextInput(text: $updatedNameBuffer.mutable, placeholder: "list name").with(classes: ["list-name", "list-name-input"]).with { widget in
              _ = widget.onMounted {
                widget.requestFocus()
              }

              widget.onKeyUp {
                if $0.key == .Return {
                  experimentalStore.commit(.updateTodoListName(listId: list?.id ?? -1, name: updatedNameBuffer))
                  editingName = false
                }
              }
            }
          } else {
            Text(list?.name ?? "").with(classes: ["list-name"]).onClick {
              if editable {
                editingName = true
                updatedNameBuffer = list?.name ?? ""
              }
            }
          }
        }

        Dynamic($editable) {
          if editable {
            Button().withContent {
              Text("add todo")
            }.onClick {
              experimentalStore.commit(.addTodoItem(listId: list!.id))
            }
          }
        }
      }

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
        (\.$margin, Insets(bottom: 48))
      }

      Experimental.Style(".list-name") {
        (\.$foreground, .white)
        (\.$fontWeight, .bold)
        (\.$fontSize, 36)
        (\.$margin, Insets(right: 24))
      }

      Experimental.Style(".list-name-input") {
        (\.$width, 200)
      }

      Experimental.Style(".todo-item-list") {
        (\.$alignSelf, .stretch)
        (\.$shrink, 1)
        (\.$overflowY, .scroll)
      }
    }
  }
}
