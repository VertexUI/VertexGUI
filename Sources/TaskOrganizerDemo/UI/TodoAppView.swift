import SwiftGUI
import ExperimentalReactiveProperties

public class TodoAppView: SingleChildWidget {
  public enum Mode {
    case SelectedList, Search
  }

  @Inject
  private var store: TodoStore

  /*private var todoLists: [TodoList] {
    store.state.lists
  }*/

  @Reference
  private var activeViewTopSpace: Space
  @ReactiveProperties.MutableProperty
  private var mode: Mode = .SelectedList
  @ExperimentalReactiveProperties.MutableProperty
  private var searchQuery: String = ""

  public init() {
    super.init()
  }

  override public func buildChild() -> Widget {
    Experimental.Container(styleProperties: {
      ($0.background, AppTheme.backgroundColor)
    }) { [unowned self] in
      Experimental.DefaultTheme()

      Column(spacing: 32) {
        Column.Item(grow: 1, crossAlignment: .Stretch) {
          Row {
            Row.Item(grow: 0, crossAlignment: .Stretch) {
              buildMenu()
            }

            Row.Item(grow: 1, crossAlignment: .Stretch) {
              buildActiveView()
            }
          }
        }
      }
    }
  }

  private func buildMenu() -> Widget {
    ConstrainedSize(minSize: DSize2(400, 0), maxSize: DSize2(400, .infinity)) {
      Border(right: 1, color: appTheme.backgroundColor.darkened(40)) {
        Column { [unowned self] in
          Column.Item(crossAlignment: .Stretch) {
            buildSearch()
          }

          Experimental.Container(styleProperties: {
            ($0.padding, Insets(all: 64))
          }) {
            Experimental.Style(".button", Experimental.Button.self) {
              ($0.background, Color.yellow)
              ($0.padding, Insets(all: 16))
              ($0.foreground, Color.white)
            }

            Experimental.Style(".button:hover") {
              Experimental.StyleProperties(Experimental.Button.self) {
                ($0.background, Color.red)
              }
            }

            Experimental.Button(classes: ["button"]) {
              Experimental.Text(styleProperties: {
                ($0.fontWeight, FontWeight.bold)
                ($0.fontSize, 20.0)
                ($0.textColor, Color.black)
              }, "New List")
            }.onClick { [unowned self] in
              handleNewListClick()
            }
          }

          Column.Item(crossAlignment: .Stretch) {
            List(store.$state.compute { $0.lists }) {
              buildMenuListItem(for: $0)
            }
          }
        }
      }
    }
  }

  private func buildSearch() -> Widget {
    Background(fill: appTheme.backgroundColor) { [unowned self] in
      Padding(all: 32) {
        Row(spacing: 0) {
          Row.Item(grow: 1, margins: Margins(right: 24)) {
            Experimental.TextInput(mutableText: $searchQuery, placeholder: "search")
          }

          Row.Item(crossAlignment: .Center) {
            Spaceholder(display: ReactiveProperties.ComputedProperty<Bool>([$mode.any]) { [unowned self] in
              return mode == .Search
            }, dimension: .Vertical) {
              Experimental.Button {
                Text("cancel")
              } onClick: {
                mode = .SelectedList
              }
            }
          }
        }
      }
    }
  }

  private func buildMenuListItem(for list: TodoList) -> Widget {
    MouseArea {
      Experimental.Container(styleProperties: {
        ($0.padding, Insets(all: 16))
        ($0.borderWidths, Experimental.Border.BorderWidths(bottom: 1.0))
        ($0.borderColor, Color.white)
      }) {

        Row(spacing: 16) {
          Row.Item(crossAlignment: .Center) {
            Experimental.Container(styleProperties: {
              ($0.background, list.color)
              ($0.padding, Insets(all: 8))
            }) {
              MaterialIcon(.formatListBulletedSquare, color: .white)
            }
          }

          Row.Item(crossAlignment: .Center) {
            Experimental.Text(styleProperties: {
              ($0.textColor, Color.white)
            }, list.name).with(classes: ["list-item-name"])
          }
        }
      }
    } onClick: { [unowned self] _ in
      store.commit(.SelectList(list.id))
      mode = .SelectedList
    }
  }

  private func buildActiveView() -> Widget {
    return Background(fill: appTheme.backgroundColor) { [unowned self] in
      Column {
        Space(DSize2(0, 0)).connect(ref: $activeViewTopSpace)

        Column.Item(grow: 1, crossAlignment: .Stretch) {
          Padding(all: 32) {
            ObservingBuilder($mode) {
              switch mode {
              case .SelectedList:
                return ObservingBuilder(store.getters.$selectedList.compute { $0?.id }) {
                  if let list = store.getters.selectedList {
                    return TodoListView(store.getters.$selectedList.compute { $0! })
                  } else {
                    return Center {
                      Text("No list selected.", fontSize: 24, fontWeight: .bold, color: .grey)
                    }
                  }
                }

              case .Search:
                return SearchResultsView()
              }
            }
          }
        }
      }
    }
  }

  private func handleNewListClick() {
    store.commit(.AddList)
  }
}
