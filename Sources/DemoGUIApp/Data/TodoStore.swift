import WidgetGUI

public class TodoStore: ReduxStore<TodoState, TodoGetters, TodoAction> {
  public init() {
    super.init(initialState: TodoState())
  }

  override public func reduce(_ action: TodoAction) -> TodoState {
    var newState = state
    
    switch action {
    case let .SelectList(listId):
      newState.selectedListId = listId

    case let .AddList:
      newState.lists.append(TodoList(id: newState.nextListId, name: "New List", color: .Yellow, items: []))
      newState.nextListId += 1

    case let .AddItem(listId):
      let item = TodoItem(description: "New Item")
      for (index, var list) in newState.lists.enumerated() {
        if list.id == listId {
          list.items.append(item)
          newState.lists[index] = list
          break
        }
      }

    case let .Search(query):
      newState.searchResult = getSearchResult(query)
    }

    return newState
  }

  private func getSearchResult(_ query: String) -> TodoSearchResult {
    TodoSearchResult(query: query, filteredLists: [])
  }
}

public struct TodoState {
  public var nextListId: Int = 0
  public var lists: [TodoList] = []
  public var selectedListId: Int? = nil
  public var searchResult: TodoSearchResult? = nil
}

public class TodoGetters: ReduxGetters<TodoState> {
  @ReduxGetter(compute: { (state: State) in
    if let id = state.selectedListId {
      return state.lists.first { $0.id == id }
    }
    return nil
  })
  public var selectedList: TodoList?
}

public enum TodoAction {
  case SelectList(_ listId: Int)
  case AddList
  case AddItem(listId: Int)
  case Search(_ query: String)
}