import SwiftGUI

public class NavigationStore: ReduxStore<NavigationState, NavigationGetters, NavigationMutation, NavigationAction> {
  public init() {
    super.init(initialState: State())
  }

  override public func performMutation(state: inout State, mutation: Mutation) {
    switch mutation {
    case let .setSelectedListId(id):
      state.selectedListId = id
    case let .updateMainViewRoute(route):
      state.previousMainViewRoute = state.mainViewRoute
      state.mainViewRoute = route
    }
  }
}

public struct NavigationState {
  public var selectedListId: Int = -1
  public var mainViewRoute: MainViewRoute = .none
  public var previousMainViewRoute: MainViewRoute? = nil
}

public enum MainViewRoute {
  case none
  case selectedList
  case searchResults
}

public class NavigationGetters: ReduxGetters<NavigationState> {

}

public enum NavigationMutation {
  case setSelectedListId(Int)
  case updateMainViewRoute(MainViewRoute)
}

public enum NavigationAction {

}