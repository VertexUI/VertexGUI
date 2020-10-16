public struct TodoSearchResult {
  public var query: String
  public var filteredLists: [FilteredTodoList]
}

public struct FilteredTodoList {
  public var baseList: TodoList
  public var filteredIndices: [Int]
}