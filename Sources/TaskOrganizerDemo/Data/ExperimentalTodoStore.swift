import SwiftGUI
import CXShim

public class ExperimentalTodoStore: Experimental.Store<ExperimentalTodoStore.State, ExperimentalTodoStore.Mutation, ExperimentalTodoStore.Action> {
  public init() {
    super.init(initialState: State())
  }

  override public func perform(mutation: Mutation, state: SetterProxy) {
    switch mutation {
    case .addList:
      state.lists.append(TodoList(id: state.nextListId, name: "new list", color: .lightBlue, items: []))
      state.nextListId += 1
    case let .setSelectedListId(id):
      state.selectedListId = id
    case let .setSearchQuery(query):
      state.searchQuery = query
    }
  }

  override public func perform(action: Action) -> Future<Void, Error> {
    switch action {
    case let .updateSearchResults(query):
      commit(.setSearchQuery(query))
    }

    return Future { resolve in
      resolve(.success(()))
    }
  }

  public struct State {
    public var nextListId = 0
    public var lists: [TodoList] = []

    public var selectedListId = -1

    public var searchQuery: String = ""
  }

  public enum Mutation {
    case addList
    case setSelectedListId(Int)
    case setSearchQuery(String)
  }

  public enum Action {
    case updateSearchResults(query: String)
  }
}