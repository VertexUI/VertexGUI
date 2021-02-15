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

      buildMenu()
      buildActiveView()
    }
  }

  private func buildMenu() -> Widget {
    Experimental.Container(styleProperties: {
      ($0.layout, SimpleLinearLayout.self)
      ($0.maxWidth, 200.0)
      (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.stretch)
      (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
    }) { [unowned self] in
      buildSearch()

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
            ($0.foreground, Color.black)
          }, "New List")
        }.onClick { [unowned self] in
          handleNewListClick()
        }
      }

      Experimental.List(styleProperties: {
        ($0.overflowY, Overflow.scroll)
        (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.stretch)
        (SimpleLinearLayout.ChildKeys.shrink, 1.0)
        ($0.foreground, Color.white)
      }, ExperimentalReactiveProperties.ComputedProperty(compute: {
        todoStore.state.lists
      }, dependencies: [todoStore.$state])) {
        buildMenuListItem(for: $0)
      }
    }
  }

  private func buildSearch() -> Widget {
    Experimental.Container(styleProperties: {
      ($0.background, AppTheme.backgroundColor)
      ($0.padding, Insets(all: 32))
    }) { [unowned self] in
      Experimental.TextInput(mutableText: ExperimentalReactiveProperties.MutableComputedProperty(compute: {
        searchStore.state.searchQuery
      }, apply: {
        searchStore.commit(.updateQuery($0))
      }, dependencies: [searchStore.$state]), placeholder: "search")

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

  private func buildMenuListItem(for list: TodoList) -> Widget {
    Experimental.Container(styleProperties: {
      ($0.padding, Insets(all: 16))
      ($0.borderWidth, BorderWidth(bottom: 1.0))
      ($0.borderColor, Color.white)
      ($0.foreground, Color.white)
    }) {
      Experimental.Container(styleProperties: {
        ($0.background, list.color)
        ($0.padding, Insets(all: 8))
        (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.center)
      }) {
        MaterialIcon(.formatListBulletedSquare, color: .white)
      }

      Experimental.Text(styleProperties: { 
        (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.center)
        ($0.foreground, Color.white)
        ($0.padding, Insets(left: 8))
      }, list.name).with(classes: ["list-item-name"])
    }.onClick { [unowned self] in
      navigationStore.commit(.updateMainViewRoute(.selectedList(list.id)))
    }
  }

  private func buildActiveView() -> Widget {
    return Experimental.Container(styleProperties: { _ in
      (SimpleLinearLayout.ChildKeys.grow, 1.0)
      (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
      (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.center)
    }) { [unowned self] in
      Space(DSize2(0, 0)).connect(ref: $activeViewTopSpace)

      ReactiveContent(navigationStore.$state) {
        switch navigationStore.state.mainViewRoute {
        case .none:
          Experimental.Text(styleProperties: {
            ($0.foreground, Color.white)
            ($0.fontSize, 24.0)
            ($0.fontWeight, FontWeight.bold)
            ($0.opacity, 0.5)
            (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.center)
          }, "no list selected")

        case let .selectedList(id):
          TodoListView(listId: ExperimentalReactiveProperties.ComputedProperty(compute: {
            if case let .selectedList(id) = navigationStore.state.mainViewRoute {
              return id
            }
            return -1
          }, dependencies: [navigationStore.$state]))

        case .searchResults:
          SearchResultsView()
        }
      }
    }
  }

  private func handleNewListClick() {
    todoStore.commit(.AddList)
  }
}
