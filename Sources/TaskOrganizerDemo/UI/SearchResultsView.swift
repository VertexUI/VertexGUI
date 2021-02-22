import SwiftGUI

public class SearchResultsView: ContentfulWidget {
  @Inject
  private var todoStore: TodoStore

  @Inject
  private var searchStore: SearchStore

  @ComputedProperty
  var searchResultsByListId: [Int: [SearchStore.SearchResult]]

  override public init() {
    super.init()
    _ = onDependenciesInjected { [unowned self] in
      _searchResultsByListId.reinit(compute: {
        searchStore.state.searchResults.reduce(into: [Int: [SearchStore.SearchResult]]()) {
          if $0[$1.listId] == nil {
            $0[$1.listId] = []
          }
          $0[$1.listId]!.append($1)
        }
      }, dependencies: [searchStore.$state])
    }
  }

  @ExpDirectContentBuilder override public var content: ExpDirectContent {
    Container().with(styleProperties: { _ in
      (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
      (SimpleLinearLayout.ParentKeys.alignContent, SimpleLinearLayout.Align.stretch)
    }).withContent {
      searchResultsByListId.map { (listId, searchResults) in
        Container().with(classes: ["list"], styleProperties: { _ in
          (SimpleLinearLayout.ParentKeys.direction, SimpleLinearLayout.Direction.column)
          (SimpleLinearLayout.ParentKeys.alignContent, SimpleLinearLayout.Align.stretch)
        }).withContent {
          buildListHeader(listId)

          searchResults.map {
            buildSearchResult($0)
          }
        }
      }
    }
  }

  func buildListHeader(_ listId: Int) -> Widget {
    Text(styleProperties: {
      ($0.foreground, Color.white)
      ($0.fontWeight, FontWeight.bold)
      ($0.fontSize, 36.0)
    }, todoStore.state.lists.first { $0.id == listId }!.name)
  }

  func buildSearchResult(_ result: SearchStore.SearchResult) -> Widget {
    TodoListItemView(todoStore.state.lists.first { $0.id == result.listId }!.items.first { $0.id == result.itemId }!)
  }

  override public var style: Style {
    Style("&") {
      ($0.overflowY, Overflow.scroll)

      Style(".list") {
        (SimpleLinearLayout.ChildKeys.margin, Insets(bottom: 64))
      }
    }
  }

  /*@ComputedProperty
  private var searchResult: TodoSearchResult?

  @ComputedProperty
  private var searchQuery: String?*/

  //override public func addedToParent() {
    /*_searchResult.dependencies = [store.$state.any]
    _searchResult.compute = { [unowned self] in
      store.state.searchResult
    }
    _searchQuery.dependencies = [store.$state.any]
    _searchQuery.compute = { [unowned self] in
      store.state.searchQuery
    }*/
  //}

  //override public func buildChild() -> Widget {
    /*ObservingBuilder($searchResult, $searchQuery) { [unowned self] in
      Column(spacing: 48) {

        /*if let searchQuery = searchQuery {
          Text("Results for \"\(searchQuery)\"", fontSize: 48, fontWeight: .bold)

          if let searchResult = searchResult {
            searchResult.filteredLists.map { list in
              TodoListView(StaticProperty(list), editable: false, checkable: true)
            }
          }
        }*/
      }
    }*/
  //  Space(.zero)
  //}
}
