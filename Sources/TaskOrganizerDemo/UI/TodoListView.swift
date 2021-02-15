import SwiftGUI
import ExperimentalReactiveProperties

public class TodoListView: Experimental.ComposedWidget {
  @Inject
  private var store: TodoStore

  @ExperimentalReactiveProperties.ObservableProperty
  private var listId: Int
  @ExperimentalReactiveProperties.ComputedProperty
  private var list: TodoList
  @ExperimentalReactiveProperties.MutableProperty
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
      }, dependencies: [$listId, store.$state])
    }
  }

  override public func performBuild() {
    rootChild = Experimental.Container(styleProperties: { _ in
      (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
    }) { [unowned self] in

      Experimental.Container(styleProperties: { _ in
        (SimpleLinearLayout.ParentKeys.alignContent, SimpleLinearLayout.Align.center)
      }) {

        Experimental.Text(styleProperties: {
          ($0.foreground, Color.white)
          ($0.fontWeight, FontWeight.bold)
          ($0.fontSize, 36.0)
        }, list.name)

        Space(DSize2(24, 0))

        ReactiveContent($editable) {
          if editable {
            Experimental.Button {
              Experimental.Text("add todo")
            } onClick: {
              handleAddTodoClick()
            }
          }
        }
      }

      Space(DSize2(0, 48))

      Experimental.List(styleProperties: {
        (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.stretch)
        (SimpleLinearLayout.ChildKeys.shrink, 1.0)
        ($0.overflowY, Overflow.scroll)
      }, ExperimentalReactiveProperties.ComputedProperty<[TodoItem]>(compute: {
        list.items
      }, dependencies: [$list])) {
        build(todo: $0)
      }
    }
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

  func build(todo: TodoItem) -> Widget {
    TodoListItemView(todo, editable: editable, checkable: checkable)
  }

  private func handleAddTodoClick() {
    store.commit(.AddItem(listId: list.id))
  }
}
