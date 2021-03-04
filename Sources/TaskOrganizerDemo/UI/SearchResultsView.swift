import SwiftGUI

public class SearchResultsView: ContentfulWidget {
  @Inject
  private var store: ExperimentalTodoStore

  @ExpDirectContentBuilder override public var content: ExpDirectContent {
    Container().with(classes: ["lists-container"]).withContent { [unowned self] in

      Dynamic(store.$state.searchResult) {

        (store.state.searchResult?.filteredLists ?? []).map { list in
          Container().with(classes: ["list"]).withContent {
            buildListHeader(list)

            list.items.map {
              buildSearchResult($0)
            }
          }
        }
      }
    }
  }

  func buildListHeader(_ list: TodoListProtocol) -> Widget {
    Text(classes: ["list-header"], list.name)
  }

  func buildSearchResult(_ todoItem: TodoItem) -> Widget {
    TodoListItemView(todoItem)
  }

  override public var experimentalStyle: Experimental.Style {
    Experimental.Style("&") {} nested: {
      Experimental.Style(".lists-container", Container.self) {
        (\.$direction, .column)
        (\.$overflowY, .scroll)
      }

      Experimental.Style(".list", Container.self) {
        (\.$direction, .column)
        (\.$margin, Insets(bottom: 64))
      }

      Experimental.Style(".list-header") {
        (\.$margin, Insets(bottom: 32))
        (\.$fontWeight, .bold)
        (\.$fontSize, 36.0)
      }
    }
  }
}
