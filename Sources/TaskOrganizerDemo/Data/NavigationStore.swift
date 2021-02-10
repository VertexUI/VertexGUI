import SwiftGUI

public class NavigationStore: ReduxStore<NavigationState, NavigationGetters, NavigationMutation, NavigationAction> {
  public init() {
    super.init(initialState: State())
  }

  override public func performMutation(state: inout State, mutation: Mutation) {
    switch mutation {
    case let .updateMainViewRoute(route):
      state.mainViewRoute = route
    }
  }
}

public struct NavigationState {
  public var mainViewRoute: MainViewRoute = .none
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