public struct TodoSearcher {
  public static func search(query: String, lists: [TodoList]) -> TodoSearchResult {
    var newSearchResult = TodoSearchResult(query: query, filteredLists: [])

    for list in lists {
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