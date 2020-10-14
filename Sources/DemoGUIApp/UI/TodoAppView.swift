import CustomGraphicsMath
import VisualAppBase
import WidgetGUI

public class TodoAppView: SingleChildWidget {
  public enum Mode {
    case SelectedList, Search
  }

  private var todoLists = TodoList.mocks
  @Reference private var activeViewTopSpace: Space
  @Observable private var selectedList: TodoList? = nil
  @Observable private var mode: Mode = .SelectedList
  @Observable private var searchQuery: String = ""

  override public func buildChild() -> Widget {
    ThemeProvider(appTheme) { [unowned self] in
      DependencyProvider(provide: [
        Dependency(todoLists)
      ]) {
        Background(fill: appTheme.backgroundColor) { [unowned self] in
          Column(spacing: 32) {
            Column.Item(grow: 1, crossAlignment: .Stretch) {
              Row {
                Row.Item(crossAlignment: .Stretch) {
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
          }

          // TODO: implement Flex shrink
          Column.Item(grow: 0, crossAlignment: .Stretch) {
            ScrollArea {
              Padding(all: 32) {
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

  private func buildSearch() -> Widget {
    Background(fill: appTheme.backgroundColor) { [unowned self] in
      Padding(all: 32) {
        //ConstrainedSize(minSize: DSize2(300, 0), maxSize: DSize2(300, .infinity)) {
          //Padding(all: 8) {
            Row(spacing: 24) {
              Row.Item(grow: 1) {
                TextField {
                  searchQuery = $0
                }.onFocusChanged.chain {
                  if $0 {
                    mode = .Search
                  }
                }
              }

              Row.Item(crossAlignment: .Center) {
                ObservingBuilder($mode) {
                  if mode == .Search {
                    return MouseArea {
                      Button {
                        Text("cancel")
                      }
                    } onClick: { _ in
                      mode = .SelectedList
                    }
                  } else {
                    return Space(.zero)
                  }
                }
              }
            }
          }
        //}
      //}
    }.with { [unowned self] in
      _ = onDestroy(
        $0.onSizeChanged {
          activeViewTopSpace.preferredSize = $0
        })
    }
  }

  private func buildMenuListItem(for list: TodoList) -> Widget {
    MouseArea {
      MouseInteraction {
        Border(bottom: 2, color: appTheme.backgroundColor.darkened(40)) {
          Background {
            Padding(all: 16) {
              Row(spacing: 24) {
                Background(fill: list.color) {
                  Padding(all: 8) {
                    MaterialIcon(.formatListBulletedSquare, color: .White)
                  }
                }

                Row.Item(crossAlignment: .Center) {
                  Text(list.name)
                }
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
      selectedList = list
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
                ObservingBuilder($selectedList) {
                  if let selectedList = selectedList {
                    return TodoListView(selectedList)
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
}
