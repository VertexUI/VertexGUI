import CustomGraphicsMath
import VisualAppBase
import WidgetGUI

public class TodoAppView: SingleChildWidget {
  public enum Mode {
    case SelectedList, Search
  }

  @Inject private var store: TodoStore

  private var todoLists: [TodoList] {
    store.state.lists
  }

  @Reference private var activeViewTopSpace: Space
  @MutableProperty private var mode: Mode = .SelectedList
  @MutableProperty private var searchQuery: String = ""

  override public func buildChild() -> Widget {
    ThemeProvider(appTheme) { [unowned self] in
      DependencyProvider(provide: [
        Dependency(todoLists)
      ]) {
        Background(fill: appTheme.backgroundColor) { [unowned self] in
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
    }
  }

  private func buildMenu() -> Widget {
    RenderGroup {
      Border(right: 1, color: appTheme.backgroundColor.darkened(40)) {
        Column { [unowned self] in
          Column.Item(crossAlignment: .Stretch) {
            buildSearch()
          }

          Button {
            Text("New List")
          } onClick: { [unowned self] _ in
            handleNewListClick()
          }

          ObservingBuilder(store.$state) {
            Column {
              // TODO: implement Flex shrink
              Column.Item(grow: 0, crossAlignment: .Stretch) {
                ScrollArea {
                  Padding(all: 0) {
                    Column(spacing: 24) {
                      Text("Lists", fontSize: 24, fontWeight: .Bold)

                      Column.Item(crossAlignment: .Stretch) {
                        Column {
                          todoLists.map { list in
                            Column.Item(crossAlignment: .Stretch) {
                              buildMenuListItem(for: list)
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  private func buildSearch() -> Widget {
    Background(fill: appTheme.backgroundColor) { [unowned self] in
      Padding(all: 32) {
        ConstrainedSize(minSize: DSize2(400, 0)) {
          Row(spacing: 0) {
            Row.Item(grow: 1, margins: Margins(right: 24)) {
              TextField {
                searchQuery = $0
              }.onFocusChanged.chain {
                if $0 {
                  mode = .Search
                }
              }
            }

            Row.Item(crossAlignment: .Center) {
              Spaceholder(display: ComputedProperty<Bool>([$mode.any]) { [unowned self] in
                return mode == .Search
              }, dimension: .Vertical) {
                Button {
                  Text("cancel")
                } onClick: { _ in
                  mode = .SelectedList
                }
              }
            }
          }
        }
      }
    }
  }

  private func buildMenuListItem(for list: TodoList) -> Widget {
    MouseArea {
      MouseInteraction {
        Border(bottom: 2, color: appTheme.backgroundColor.darkened(40)) {
          Background {
            Padding(all: 16) {
              SimpleRow {
                Background(fill: list.color) {
                  Padding(all: 8) {
                    MaterialIcon(.formatListBulletedSquare, color: .White)
                  }
                }

                Space(DSize2(16, 0))

                Text(list.name)
              }
            }
          }
        }
      }.with(
        config: MouseInteraction.PartialConfig {
          $0.stateConfigs = [
            .Normal: Background.PartialConfig {
              $0.fill = appTheme.backgroundColor
              $0.fillTransition = Background.FillTransition(duration: 0.3)
            },
            .Hover: Background.PartialConfig {
              $0.fill = appTheme.primaryColor
              $0.fillTransition = Background.FillTransition(duration: 0.3)
            },
            .Active: Background.PartialConfig {
              $0.fill = appTheme.primaryColor.darkened(50)
              $0.fillTransition = Background.FillTransition(duration: 0.3)
            },
          ]
        })
    } onClick: { [unowned self] _ in
      store.dispatch(.SelectList(list.id))
      mode = .SelectedList
    }
  }

  private func buildActiveView() -> Widget {
    Background(fill: appTheme.backgroundColor) { [unowned self] in
      Column {
        Space(DSize2(0, 0)).connect(ref: $activeViewTopSpace)

        Column.Item(grow: 1, crossAlignment: .Stretch) {
          Padding(all: 32) {
            ObservingBuilder($mode) {
              switch mode {
              case .SelectedList:
                ObservingBuilder(store.getters.$selectedList) {
                  if let selectedList = store.getters.selectedList {
                    return TodoListView(StaticProperty(selectedList))
                  } else {
                    return Center {
                      Text("No list selected.", fontSize: 24, fontWeight: .Bold, color: .Grey)
                    }
                  }
                }

              case .Search:
                SearchResultsView(query: $searchQuery)
              }
            }
          }
        }
      }
    }
  }

  private func handleNewListClick() {
    store.dispatch(.AddList)
  }
}
