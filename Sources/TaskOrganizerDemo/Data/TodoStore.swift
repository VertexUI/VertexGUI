import WidgetGUI

public class TodoStore: ReduxStore<TodoState, TodoGetters, TodoAction> {
  public init() {
    super.init(initialState: TodoState())
  }

  override public func reduce(_ action: TodoAction, next: (@escaping () -> ()) -> ()) -> TodoState {
    var newState = state
    
    outer: switch action {
    case let .SelectList(listId):
      newState.selectedListId = listId

    case let .AddList:
      newState.lists.append(TodoList(id: newState.nextListId, name: "New List", color: .Yellow, items: []))
      newState.nextListId += 1

    case let .UpdateListName(newName, listId):
      for (index, var list) in newState.lists.enumerated() {
        if list.id == listId {
          list.name = newName
          newState.lists[index] = list
          break
        }
      }

    case let .AddItem(listId):
      let item = TodoItem(description: "New Item")
      for (index, var list) in newState.lists.enumerated() {
        if list.id == listId {
          list.items.append(item)
          newState.lists[index] = list
          break
        }
      }

    case let .UpdateTodoItem(updatedItem):
      for (listIndex, var list) in newState.lists.enumerated() {
        for (itemIndex, var item) in list.items.enumerated() {
          if item.id == updatedItem.id {
            list.items[itemIndex] = updatedItem
            newState.lists[listIndex] = list
            next { [unowned self] in
              dispatch(.UpdateCurrentSearch)
            }
            break outer
          }
        }
      }

      fatalError("tried to update todo item that does not exist")

    case let .Search(query):
      newState.searchResult = getSearchResult(query)

    case .UpdateCurrentSearch:
      if let searchResult = state.searchResult {
        next { [unowned self] in
          dispatch(.Search(searchResult.query))
        }
      }
    }

    return newState
  }

  private func getSearchResult(_ query: String) -> TodoSearchResult {
    if let previousSearchResult = state.searchResult {

    }

    var newSearchResult = TodoSearchResult(query: query, filteredLists: [])

    for list in state.lists {
      var filteredList = FilteredTodoList(baseList: list, filteredIndices: [])
      for (index, item) in list.items.enumerated() {
        if item.description.lowercased().contains(query.lowercased()) {
          filteredList.filteredIndices.append(index)
        }
      }
      newSearchResult.filteredLists.append(filteredList)
    }

    return newSearchResult
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
  case UpdateListName(_ newName: String, listId: Int)
  case AddItem(listId: Int)
  case UpdateTodoItem(_ updatedItem: TodoItem)
  case Search(_ query: String)
  case UpdateCurrentSearch
}