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
    Text(list.name).with(classes: ["list-header"])
  }

  func buildSearchResult(_ todoItem: TodoItem) -> Widget {
    TodoListItemView(todoItem).with(classes: ["list-item"])
  }

  override public var experimentalStyle: Experimental.Style {
    Experimental.Style("&") {} nested: {
      Experimental.Style(".lists-container", Container.self) {
        (\.$direction, .column)
        (\.$overflowY, .scroll)
        (\.$alignContent, .stretch)
      }

      Experimental.Style(".list", Container.self) {
        (\.$direction, .column)
        (\.$margin, Insets(bottom: 64))
        (\.$alignContent, .stretch)
      }

      Experimental.Style(".list-header") {
        (\.$margin, Insets(bottom: 32))
        (\.$fontWeight, .bold)
        (\.$fontSize, 36.0)
      }
    }
  }
}
