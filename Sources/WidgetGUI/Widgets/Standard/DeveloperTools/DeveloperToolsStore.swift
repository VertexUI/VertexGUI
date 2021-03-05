extension DeveloperTools {
  public class Store: Experimental.Store<Store.State, Store.Mutation, Store.Action> {
    public init() {
      super.init(initialState: State())
    }

    override public func perform(mutation: Mutation, state: SetterProxy) {
      switch mutation {
      case let .setActiveMainRoute(route):
        state.activateMainRoute = route
      case let .setInspectedWidget(widget):
        state.inspectedWidget = widget
      }
    }

    public struct State {
      public var activateMainRoute: MainRoute = .inspector
      public var inspectedWidget: Widget? = nil
    }

    public enum Mutation {
      case setActiveMainRoute(MainRoute)
      case setInspectedWidget(Widget)
    }

    public enum Action {

    }
  }
}