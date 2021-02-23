import SwiftGUI

public class NavigationStore: ReduxStore<NavigationState, NavigationGetters, NavigationMutation, NavigationAction> {
  public init() {
    super.init(initialState: State())
  }

  override public func performMutation(state: inout State, mutation: Mutation) {
    switch mutation {
    case let .updateMainViewRoute(route):
      state.previousMainViewRoute = state.mainViewRoute
      state.mainViewRoute = route
    }
  }
}

public struct NavigationState {
  public var mainViewRoute: MainViewRoute = .none
  public var previousMainViewRoute: MainViewRoute? = nil
}

public enum MainViewRoute {
  case none
  case selectedList(Int)
  case searchResults
}

public class NavigationGetters: ReduxGetters<NavigationState> {

}

public enum NavigationMutation {
  case updateMainViewRoute(MainViewRoute)
}

public enum NavigationAction {

}