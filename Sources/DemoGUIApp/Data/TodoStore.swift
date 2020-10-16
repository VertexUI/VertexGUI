import WidgetGUI

public class TodoStore: ReduxStore<TodoState, TodoAction> {
  public init() {
    super.init(initialState: TodoState())
  }

  override public func reduce(_ action: TodoAction) -> TodoState {
    var newState = state
    
    switch action {
    case let .AddList(list):
      newState.lists.append(list)

    case let .AddItem(item, listId):
      for (index, var list) in newState.lists.enumerated() {
        if list.id == listId {
          list.items.append(item)
          newState.lists[index] = list
          break
        }
      }
    }

    case let .Search(query):


    return newState
  }

  private func getSearchResult(_ query: String) {

  }
}

public struct TodoState {
  public var lists: [TodoList] = []
}

public enum TodoAction {
  case AddList(_ list: TodoList)
  case AddItem(_ item: TodoItem, listId: String)
}