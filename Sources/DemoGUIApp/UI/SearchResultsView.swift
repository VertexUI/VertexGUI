import VisualAppBase
import WidgetGUI

public class SearchResultsView: SingleChildWidget {
  @Inject
  private var store: TodoStore

  @ComputedProperty
  private var searchResult: TodoSearchResult?

  override public func addedToParent() {
    _searchResult.dependencies = [store.$state.any]
    _searchResult.compute = { [unowned self] in
      store.state.searchResult
    }
  }

  override public func buildChild() -> Widget {
    ObservingBuilder($searchResult) { [unowned self] in
      Column(spacing: 48) {

        if let searchResult = searchResult {
          Text("Results for \"\(searchResult.query)\"", fontSize: 48, fontWeight: .Bold)
          /*store.state.searchResult.filteredLists.map { list in
            TodoListView(StaticProperty(list))
          }*/
        } else {
          Text("No query")
        }
      }
    }
  }
}
