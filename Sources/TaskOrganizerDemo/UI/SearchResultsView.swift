import SwiftGUI

public class SearchResultsView: SingleChildWidget {
  @Inject
  private var store: TodoStore

  @ComputedProperty
  private var searchResult: TodoSearchResult?

  @ComputedProperty
  private var searchQuery: String?

  override public func addedToParent() {
    _searchResult.dependencies = [store.$state.any]
    _searchResult.compute = { [unowned self] in
      store.state.searchResult
    }
    _searchQuery.dependencies = [store.$state.any]
    _searchQuery.compute = { [unowned self] in
      store.state.searchQuery
    }
  }

  override public func buildChild() -> Widget {
    ObservingBuilder($searchResult, $searchQuery) { [unowned self] in
      Column(spacing: 48) {

        if let searchQuery = searchQuery {
          Text("Results for \"\(searchQuery)\"", fontSize: 48, fontWeight: .bold)

          if let searchResult = searchResult {
            searchResult.filteredLists.map { list in
              TodoListView(StaticProperty(list), editable: false, checkable: true)
            }
          }
        }
      }
    }
  }
}
