import ReactiveProperties
import SwiftGUI

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

  @MutableComputedProperty
  private var mainViewRoute: MainViewRoute

  @MutableComputedProperty
  private var searchQuery: String

  override public init() {
    super.init()
    _ = onDependenciesInjected { [unowned self] _ in
      _mainViewRoute.reinit(
        compute: {
          navigationStore.state.mainViewRoute
        },
        apply: {
          navigationStore.commit(.updateMainViewRoute($0))
        }, dependencies: [navigationStore.$state])

      _searchQuery.reinit(
        compute: {
          searchStore.state.searchQuery
        },
        apply: {
          searchStore.dispatch(.updateResults($0))
        }, dependencies: [searchStore.$state])

      _ = _searchQuery.onChanged { _ in
        if searchQuery.isEmpty {
          switch mainViewRoute {
          case .searchResults:
            mainViewRoute = navigationStore.state.previousMainViewRoute ?? .none 
          default:
            break
          }
        } else {
          switch mainViewRoute {
          case .searchResults:
            break
          default:
            mainViewRoute = .searchResults
          }
        }
      }
    }
  }

  override public func performBuild() {
    rootChild = Container().withContent { [unowned self] in
      buildMenu()
      buildActiveView()
    }
  }

  private func buildMenu() -> Widget {
    Container().with(classes: ["menu"], styleProperties: {
      ($0.layout, SimpleLinearLayout.self)
      ($0.width, 250)
    }).withContent { [unowned self] in
      buildSearch()

      Container().with(classes: ["padded-container"]).withContent {
        Button().with(classes: ["button"]).withContent {
          Text("New List")
        }.onClick { [unowned self] in
          handleNewListClick()
        }
      }

      List(
        ComputedProperty(
          compute: {
            todoStore.state.lists
          }, dependencies: [todoStore.$state])
      ).with(classes: ["menu-item-list"]).withContent {
        $0.itemSlot {
          buildMenuListItem(for: $0)
        }
      }
    }
  }

  private func buildSearch() -> Widget {
    Container().with(classes: ["padded-container"]).withContent { [unowned self] in
      TextInput(mutableText: $searchQuery, placeholder: "search").with(styleProperties: { _ in
        (SimpleLinearLayout.ChildKeys.shrink, 1.0)
        (SimpleLinearLayout.ChildKeys.grow, 1.0)
        (SimpleLinearLayout.ChildKeys.margin, Insets(right: 16))
      })

      Button().onClick {
        searchStore.dispatch(.updateResults(""))
      }.withContent {
        MaterialDesignIcon(.close)
      }
    }
  }

  private func buildMenuListItem(for list: TodoList) -> Widget {
    Container().with(classes: ["menu-item"]).withContent {
      Container().experimentalWith(styleProperties: {
        (\.$background, list.color)
        (\.$padding, Insets(all: 8))
        (\.$alignSelf, .center)
      }).withContent {
        Space(.zero)
      }

      Text(list.name).with(classes: ["list-item-name"])
    }.onClick { [unowned self] in
      navigationStore.commit(.setSelectedListId(list.id))
      if navigationStore.state.mainViewRoute != .selectedList {
        navigationStore.commit(.updateMainViewRoute(.selectedList))
      }
    }
  }

  private func buildActiveView() -> Widget {
    return Container().with(classes: ["active-view-container"]).withContent { [unowned self] in
      Space(DSize2(0, 0)).connect(ref: $activeViewTopSpace)

      Dynamic($mainViewRoute) {
        switch mainViewRoute {
        case .none:
          Text(
            styleProperties: {
              ($0.foreground, Color.white)
              ($0.fontSize, 24)
              ($0.fontWeight, FontWeight.bold)
              ($0.opacity, 0.5)
              (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.center)
            }, "no list selected")

        case let .selectedList:
          TodoListView(listId: ComputedProperty(compute: { navigationStore.state.selectedListId }, dependencies: [navigationStore.$state]))

        case .searchResults:
          SearchResultsView().with(styleProperties: {
            ($0.padding, Insets(top: 48, left: 48))
            (SimpleLinearLayout.ChildKeys.alignSelf, SimpleLinearLayout.Align.stretch)
            (SimpleLinearLayout.ChildKeys.grow, 1.0)
            (SimpleLinearLayout.ChildKeys.shrink, 1.0)
          })
        }
      }
    }
  }

  private func handleNewListClick() {
    todoStore.commit(.AddList)
  }

  override public var style: Style {
    Style("&") {
      FlatTheme(
        primaryColor: AppTheme.primaryColor, secondaryColor: AppTheme.primaryColor,
        backgroundColor: AppTheme.backgroundColor
      ).styles

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

  override public var experimentalStyle: Experimental.Style {
    Experimental.Style("&") {
      (\.$background, AppTheme.backgroundColor)
    } nested: {
      FlatTheme(
        primaryColor: AppTheme.primaryColor, secondaryColor: AppTheme.primaryColor,
        backgroundColor: AppTheme.backgroundColor
      ).experimentalStyles

      Experimental.Style(".menu", Container.self) {
        (\.$alignSelf, .stretch)
        (\.$direction, .column)
      }

      Experimental.Style(".padded-container") {
        (\.$padding, Insets(all: 32))
      }

      Experimental.Style(".menu-item-list") {
        (\.$overflowY, .scroll)
        (\.$alignSelf, .stretch)
        (\.$shrink, 1)
      }

      Experimental.Style(".menu-item") {
        (\.$foreground, .white)
        (\.$background, .transparent)
        (\.$padding, Insets(top: 16, right: 24, bottom: 16, left: 24))
        (\.$borderWidth, BorderWidth(bottom: 1.0))
        (\.$borderColor, AppTheme.listItemDividerColor)
      }

      Experimental.Style(".menu-item:hover") {
        (\.$background, AppTheme.primaryColor)
        (\.$foreground, .black)
      }

      Experimental.Style(".list-item-name") {
        (\.$alignSelf, .center)
        (\.$padding, Insets(left: 8))
      }

      Experimental.Style(".active-view-container", Container.self) {
        (\.$grow, 1)
        (\.$direction, .column)
        (\.$alignSelf, .stretch)
        (\.$justifyContent, .center)
      } nested: {

        Experimental.Style([StyleSelectorPart(type: TodoListView.self)]) {
          (\.$padding, Insets(top: 48, left: 48))
          (\.$alignSelf, .stretch)
          (\.$grow, 1)
          (\.$shrink, 1)
        }
      }
    }
  }
}
