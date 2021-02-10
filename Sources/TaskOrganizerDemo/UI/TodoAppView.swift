import SwiftGUI
import ExperimentalReactiveProperties

public class TodoAppView: SingleChildWidget {
  public enum Mode {
    case SelectedList, Search
  }

  @Inject
  private var todoStore: TodoStore

  @Inject
  private var searchStore: SearchStore

  @Inject
  private var navigationStore: NavigationStore

  /*private var todoLists: [TodoList] {
    store.state.lists
  }*/

  @Reference
  private var activeViewTopSpace: Space

  /*@ReactiveProperties.MutableProperty
  private var mode: Mode = .SelectedList*/

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
    ConstrainedSize(minSize: DSize2(400, 0), maxSize: DSize2(400, .infinity)) { [unowned self] in
      Border(right: 1, color: appTheme.backgroundColor.darkened(40)) {
        Column {
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
            Experimental.Container(styleProperties: {
              ($0.overflowY, Overflow.scroll)
            }) {
              Experimental.List(ExperimentalReactiveProperties.ComputedProperty(compute: {
                todoStore.state.lists
              }, dependencies: [todoStore.$state])) {
                buildMenuListItem(for: $0)
              }
            }
          }
        }
      }
    }
  }

  private func buildSearch() -> Widget {
    Experimental.Container(styleProperties: {
      ($0.background, AppTheme.backgroundColor)
      ($0.padding, Insets(all: 32))
    }) { [unowned self] in
      Row(spacing: 0) {
        Row.Item(grow: 1, margins: Margins(right: 24)) {
          Experimental.TextInput(mutableText: ExperimentalReactiveProperties.MutableComputedProperty(compute: {
            searchStore.state.searchQuery
          }, apply: {
            searchStore.commit(.updateQuery($0))
          }, dependencies: [searchStore.$state]), placeholder: "search")
        }

        /*Row.Item(crossAlignment: .Center) {
          Spaceholder(display: ReactiveProperties.ComputedProperty<Bool>([$mode.any]) { [unowned self] in
            return mode == .Search
          }, dimension: .Vertical) {
            Experimental.Button {
              Text("cancel")
            } onClick: {
              mode = .SelectedList
            }
          }
        }*/
      }
    }
  }

  private func buildMenuListItem(for list: TodoList) -> Widget {
    MouseArea {
      Experimental.Container(styleProperties: {
        ($0.padding, Insets(all: 16))
        ($0.borderWidth, BorderWidth(bottom: 1.0))
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
      navigationStore.commit(.updateMainViewRoute(.selectedList(list.id)))
      //mode = .SelectedList
    }
  }

  private func buildActiveView() -> Widget {
    return Background(fill: appTheme.backgroundColor) { [unowned self] in
      Column {
        Space(DSize2(0, 0)).connect(ref: $activeViewTopSpace)

        Experimental.Build(ExperimentalReactiveProperties.ComputedProperty(compute: {
          navigationStore.state.mainViewRoute
        }, dependencies: [navigationStore.$state])) {

          switch navigationStore.state.mainViewRoute {
          case .none:
            return Space(.zero)
          case let .selectedList(id):
            return TodoListView(listId: ExperimentalReactiveProperties.ComputedProperty(compute: {
              if case let .selectedList(id) = navigationStore.state.mainViewRoute {
                return id
              }
              return -1
            }, dependencies: [navigationStore.$state]))
          case .searchResults:
            return SearchResultsView()
          }
        }

        /*Column.Item(grow: 1, crossAlignment: .Stretch) {
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
        }*/
      }
    }
  }

  private func handleNewListClick() {
    todoStore.commit(.AddList)
  }
}
