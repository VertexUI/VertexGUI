import SwiftGUI
import Dispatch
import CXShim

public class TodoAppView: ContentfulWidget {
  public enum Mode {
    case SelectedList, Search
  }

  @Inject private var experimentalStore: ExperimentalTodoStore
  @Reference private var activeViewTopSpace: Space

  @State private var searchQuery: String = ""
  private var searchQuerySubscription: AnyCancellable?
  private var storeSearchQuerySubscription: AnyCancellable?

  override public init() {
    super.init()
    _ = onDependenciesInjected { [unowned self] _ in
      storeSearchQuerySubscription = experimentalStore.$state.searchQuery.sink {
        searchQuery = $0
      }

      searchQuerySubscription = $searchQuery
        .debounce(for: .seconds(0.5), scheduler: CXWrappers.DispatchQueue(wrapping: DispatchQueue.main))
        .removeDuplicates().sink {
          experimentalStore.dispatch(.updateSearchResult(query: $0))
          if $0.isEmpty {
            switch experimentalStore.state.mainViewRoute {
            case .searchResults:
              experimentalStore.commit(.setMainViewRoute(experimentalStore.state.previousMainViewRoute))
            default:
              break
            }
          } else {
            switch experimentalStore.state.mainViewRoute {
            case .searchResults:
              break
            default:
              experimentalStore.commit(.setMainViewRoute(.searchResults))
            }
          }
        }
    }
  }

  @ExpDirectContentBuilder override public var content: ExpDirectContent {
    Container().withContent { [unowned self] in
      buildMenu()
      buildActiveView()
    }
  }

  private func buildMenu() -> Widget {
    Container().with(classes: ["menu"]).withContent { [unowned self] in
      buildSearch()

      Container().with(classes: ["padded-container"]).withContent {
        Button().with(classes: ["button"]).withContent {
          Text("New List")
        }.onClick { [unowned self] in
          experimentalStore.commit(.addTodoList)
        }
      }

      List(items: experimentalStore.$state.lists.immutable).with(classes: ["menu-item-list"]).withContent {
        $0.itemSlot {
          buildMenuListItem(for: $0)
        }
      }
    }
  }

  private func buildSearch() -> Widget {
    Container().with(classes: ["padded-container", "search-container"]).withContent { [unowned self] in
      TextInput(text: $searchQuery.mutable, placeholder: "search").with(classes: ["search-input"])

      Button().onClick {
        experimentalStore.commit(.setMainViewRoute(experimentalStore.state.previousMainViewRoute))
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
      experimentalStore.commit(.setSelectedTodoListId(list.id))
      if experimentalStore.state.mainViewRoute != .selectedList {
        experimentalStore.commit(.setMainViewRoute(.selectedList))
      }
    }
  }

  private func buildActiveView() -> Widget {
    return Container().with(classes: ["active-view-container"]).withContent { [unowned self] in
      Space(DSize2(0, 0)).connect(ref: $activeViewTopSpace)

      Dynamic(experimentalStore.$state.mainViewRoute) {
        switch experimentalStore.state.mainViewRoute {
        case .none:
          Text("no list selected").with(classes: ["no-active-view-label"])

        case let .selectedList:
          TodoListView(listId: experimentalStore.$state.selectedListId.immutable).with(classes: ["active-view"])

        case .searchResults:
          SearchResultsView().with(classes: ["active-view"])
        }
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
        (\.$width, 250)
      }

      Experimental.Style(".padded-container") {
        (\.$padding, Insets(all: 32))
      }

      Experimental.Style(".search-container") {
        (\.$alignSelf, .stretch)
      }

      Experimental.Style(".search-input") {
        (\.$shrink, 1.0)
        (\.$grow, 1.0)
        (\.$margin, Insets(right: 16))
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
      }

      Experimental.Style(".active-view") {
        (\.$padding, Insets(top: 48, left: 48))
        (\.$alignSelf, .stretch)
        (\.$grow, 1)
        (\.$shrink, 1)
      }

      Experimental.Style(".no-active-view-label") {
        (\.$foreground, .white)
        (\.$fontSize, 24)
        (\.$fontWeight, .bold)
        (\.$opacity, 0.5)
        (\.$alignSelf, .center)
      }
    }
  }
}
