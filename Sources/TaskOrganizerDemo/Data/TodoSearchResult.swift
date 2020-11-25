import GfxMath

public struct TodoSearchResult {
  public var query: String
  public var filteredLists: [FilteredTodoList]
}

public struct FilteredTodoList: TodoListProtocol {
  public var baseList: TodoList
  public var filteredIndices: [Int]

  public var id: Int {
    baseList.id
  }

  public var name: String {
    baseList.name
  }

  public var color: Color {
    baseList.color
  }

  public var items: [TodoItem] {
    filteredIndices.map { baseList.items[$0] }
  }
}