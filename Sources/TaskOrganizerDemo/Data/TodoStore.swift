import Foundation
import Dispatch
import WidgetGUI

public class TodoStore: ReduxStore<TodoState, TodoGetters, TodoMutation, TodoAction> {
  public init() {
    super.init(initialState: TodoState())
  }

  override public func performMutation(state: inout State, mutation: Mutation) {
    outer: switch mutation {
    case let .AddList:
      state.lists.append(TodoList(id: state.nextListId, name: "New List", color: .yellow, items: []))
      state.nextListId += 1

    case let .UpdateListName(newName, listId):
      for (index, var list) in state.lists.enumerated() {
        if list.id == listId {
          list.name = newName
          state.lists[index] = list
          break
        }
      }

    case let .AddItem(listId):
      let item = TodoItem(description: "New Item")
      for (index, var list) in state.lists.enumerated() {
        if list.id == listId {
          list.items.append(item)
          state.lists[index] = list
          break
        }
      }

    case let .UpdateTodoItem(updatedItem):
      for (listIndex, var list) in state.lists.enumerated() {
        for (itemIndex, var item) in list.items.enumerated() {
          if item.id == updatedItem.id {
            list.items[itemIndex] = updatedItem
            state.lists[listIndex] = list
            break outer
          }
        }
      }

      fatalError("tried to update todo item that does not exist")

    case let .SetSearchQuery(query):
      state.searchQuery = query

    case let .UpdateSearchResult(searchResult):
      state.searchResult = searchResult
    }
  }

  override public func performAction(action: Action) {
    switch action {
    case let .UpdateTodoItem(updatedItem):
      commit(.UpdateTodoItem(updatedItem))
      dispatch(.UpdateCurrentSearch)
    case let .Search(query):
      commit(.SetSearchQuery(query))
      let tmpState = state
      DispatchQueue.global().async { [unowned self] in
        let searchResult = getSearchResult(query, state: tmpState)
        DispatchQueue.main.async {
          commit(.UpdateSearchResult(searchResult))
        }
      }
    case .UpdateCurrentSearch:
      if let searchResult = state.searchResult {
        dispatch(.Search(searchResult.query))
      }
    }
  }

  private func getSearchResult(_ query: String, state: State) -> TodoSearchResult {
    /*if let previousSearchResult = state.searchResult {

    }*/

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
  public var searchQuery: String? = nil
  public var searchResult: TodoSearchResult? = nil
}

public class TodoGetters: ReduxGetters<TodoState> {
  /*@ReduxGetter(compute: { (state: State) in
    if let id = state.selectedListId {
      return state.lists.first { $0.id == id }
    }
    return nil
  })
  public var selectedList: TodoList?*/
}

public enum TodoMutation {
  case AddList
  case UpdateTodoItem(_ updatedItem: TodoItem)
  case UpdateListName(_ newName: String, listId: Int)
  case AddItem(listId: Int)
  case SetSearchQuery(_ query: String) 
  case UpdateSearchResult(_ searchResult: TodoSearchResult)
}

public enum TodoAction {
  case UpdateTodoItem(_ updatedItem: TodoItem)
  case Search(_ query: String)
  case UpdateCurrentSearch
}