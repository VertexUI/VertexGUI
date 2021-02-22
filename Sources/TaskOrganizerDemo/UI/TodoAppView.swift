import SwiftGUI
import ReactiveProperties

public class TodoAppView: ComposedWidget {
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

  /*@MutableProperty
  private var mode: Mode = .SelectedList*/

  @MutableProperty
  private var searchQuery: String = ""

  override public func performBuild() {
    rootChild = Container().with(styleProperties: {
      ($0.background, AppTheme.backgroundColor)
    }).withContent { [unowned self] in
      buildMenu()
      buildActiveView()
    }
  }

  private func buildMenu() -> Widget {
    Container().with(styleProperties: {
      ($0.layout, SimpleLinearLayout.self)
      ($0.width, 200)
      (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.stretch)
      (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
    }).withContent { [unowned self] in
      buildSearch()

      Container().with(styleProperties: {
        ($0.padding, 32)
      }).withContent {
        Button().with(classes: ["button"]).withContent {
          Text(styleProperties: {
            ($0.fontWeight, FontWeight.bold)
            ($0.fontSize, 20)
            ($0.foreground, Color.black)
          }, "New List")
        }.onClick { [unowned self] in
          handleNewListClick()
        }
      }

      List(ComputedProperty(compute: {
        todoStore.state.lists
      }, dependencies: [todoStore.$state])).with(styleProperties: {
        ($0.overflowY, Overflow.scroll)
        (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.stretch)
        (SimpleLinearLayout.ChildKeys.shrink, 1.0)
        ($0.foreground, Color.white)
      }).withContent {
        $0.itemSlot {
          buildMenuListItem(for: $0)
        }
      }
    }
  }

  private func buildSearch() -> Widget {
    Container().with(styleProperties: {
      ($0.padding, Insets(all: 32))
      (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.stretch)
    }).withContent { [unowned self] in
      TextInput(styleProperties: { _ in
        (SimpleLinearLayout.ChildKeys.shrink, 1.0)
        (SimpleLinearLayout.ChildKeys.grow, 1.0)
      }, mutableText: MutableComputedProperty(compute: {
        searchStore.state.searchQuery
      }, apply: {
        searchStore.commit(.updateQuery($0))
      }, dependencies: [searchStore.$state]), placeholder: "search")

        /*Row.Item(crossAlignment: .Center) {
          Spaceholder(display: ReactiveProperties.ComputedProperty<Bool>([$mode.any]) { [unowned self] in
            return mode == .Search
          }, dimension: .Vertical) {
            Button().withContent {
              Text("cancel")
            } onClick: {
              mode = .SelectedList
            }
          }
        }*/
    }
  }

  private func buildMenuListItem(for list: TodoList) -> Widget {
    Container().with(classes: ["menu-item"], styleProperties: {
      ($0.padding, Insets(all: 16))
      ($0.borderWidth, BorderWidth(bottom: 1.0))
      ($0.borderColor, Color.white)
    }).withContent {
      Container().with(styleProperties: {
        ($0.background, list.color)
        ($0.padding, Insets(all: 8))
        (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.center)
      }).withContent {
        Space(.zero)
        //MaterialIcon(.formatListBulletedSquare, color: .white)
      }

      Text(styleProperties: { 
        (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.center)
        ($0.padding, Insets(left: 8))
      }, list.name).with(classes: ["list-item-name"])
    }.onClick { [unowned self] in
      navigationStore.commit(.updateMainViewRoute(.selectedList(list.id)))
    }
  }

  private func buildActiveView() -> Widget {
    return Container().with(styleProperties: { _ in
      (SimpleLinearLayout.ChildKeys.grow, 1.0)
      (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
      (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.stretch)
      (SimpleLinearLayout.ParentKeys.justifyContent, SimpleLinearLayout.Justify.center)
    }).withContent { [unowned self] in
      Space(DSize2(0, 0)).connect(ref: $activeViewTopSpace)

      Dynamic(navigationStore.$state) {
        switch navigationStore.state.mainViewRoute {
        case .none:
          Text(styleProperties: {
            ($0.foreground, Color.white)
            ($0.fontSize, 24)
            ($0.fontWeight, FontWeight.bold)
            ($0.opacity, 0.5)
            (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.center)
          }, "no list selected")

        case let .selectedList(id):
          TodoListView(listId: ComputedProperty(compute: {
            if case let .selectedList(id) = navigationStore.state.mainViewRoute {
              return id
            }
            return -1
          }, dependencies: [navigationStore.$state])).with(styleProperties: {
            ($0.padding, Insets(top: 48, left: 48))
            (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.stretch)
            (SimpleLinearLayout.ChildKeys.grow, 1.0)
            (SimpleLinearLayout.ChildKeys.shrink, 1.0)
          })

        case .searchResults:
          SearchResultsView()
        }
      }
    }
  }

  private func handleNewListClick() {
    todoStore.commit(.AddList)
  }

  override public var style: Style {
    Style("&") {
      FlatTheme(primaryColor: AppTheme.primaryColor, secondaryColor: AppTheme.primaryColor, backgroundColor: AppTheme.backgroundColor).styles

      Style(".button") {
        ($0.background, Color.yellow)
        ($0.padding, Insets(all: 16))
        ($0.foreground, Color.white)
      }

      Style(".button:hover") {
        ($0.background, Color.red)
      }

      Style(".menu-item") {
        ($0.foreground, Color.white)
        ($0.background, Color.transparent)
      }

      Style(".menu-item:hover") {
        ($0.background, AppTheme.primaryColor)
        ($0.foreground, Color.black)
      }
    }
  }
}
