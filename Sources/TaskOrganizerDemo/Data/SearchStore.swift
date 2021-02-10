import SwiftGUI

public class SearchStore: ReduxStore<SearchState, SearchGetters, SearchMutation, SearchAction> {
  public init() {
    super.init(initialState: SearchState())
  }

  override public func performMutation(_ state: inout State, _ mutation: Mutation) {
    
  }
}

public struct SearchState {
  public var searchQuery = ""
}

public class SearchGetters: ReduxGetters<SearchState> {

}

public enum SearchMutation {
  case updateQuery(String)
}

public enum SearchAction {

}

