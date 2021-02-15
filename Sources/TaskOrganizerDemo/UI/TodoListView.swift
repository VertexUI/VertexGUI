import SwiftGUI
import ExperimentalReactiveProperties

public class TodoListView: SingleChildWidget {
  @Inject
  private var store: TodoStore

  @ExperimentalReactiveProperties.ObservableProperty
  private var listId: Int
  @ExperimentalReactiveProperties.ComputedProperty
  private var list: TodoList
  private var editable: Bool
  private var checkable: Bool
  private var expandedItemIndices: Set<Int> = []

  @ExperimentalReactiveProperties.MutableProperty
  private var nameEditMode: Bool = false
  private var updatedNameBuffer: String = ""

  @ExperimentalReactiveProperties.MutableProperty
  private var editingItemIndex: Int? = nil
  private var updatedItemDescription: String = ""


  public init<P: ReactiveProperty>(listId listIdProperty: P, editable: Bool = true, checkable: Bool = true) where P.Value == Int {
    self.editable = editable
    self.checkable = checkable
    super.init()
    self.$listId.bind(listIdProperty)
    _ = onDependenciesInjected { [unowned self] in
      self.$list.reinit(compute: { [unowned self] in
        store.state.lists.first { $0.id == listId }!
      }, dependencies: [$listId])
    }
  }

  override public func buildChild() -> Widget {
    ScrollArea(scrollX: .Never) { [unowned self] in
      Column(spacing: 16) {
        Experimental.Text(styleProperties: {
          ($0.foreground, Color.white)
        }, "DISPLAY A LIST!")
        /*ObservingBuilder($nameEditMode) {
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

              Experimental.Button {
                Experimental.Text("done")
              } onClick: {
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
          Experimental.Button {
            Experimental.Text("Add Todo")
          } onClick: { [unowned self] in
            handleAddTodoClick()
          }
        }

        ObservingBuilder($list) {
          Column {
            list.items.enumerated().map { (index, todo) in
              build(todo: todo, index: index)
            }
          }
        }*/
      }
    }
  }

  /*@Flex.ItemBuilder private func build(todo: TodoItem, index: Int) -> [Flex.Item] {
    TodoListItemView(todo, editable: editable, checkable: checkable)

    Column.Item(crossAlignment: .Stretch) {
      Padding(left: 40 + 48) {
        Divider(color: .grey, axis: .Horizontal, thickness: 1)
      }
    }
  }

  private func handleAddTodoClick() {
    store.commit(.AddItem(listId: list.id))
  }*/
}
