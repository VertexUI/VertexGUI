extension DeveloperTools {
  public class Store: ReduxStore<Store.State, Store.Getters, Store.Mutation, Store.Action> {
    public init() {
      super.init(initialState: State())
    }

    override public func performMutation(state: inout State, mutation: Mutation) {
      switch mutation {
      case let .setInspectedWidget(widget):
        state.inspectedWidget = widget
      }
    }

    public struct State {
      public var inspectedWidget: Widget? = nil
    }

    public class Getters: ReduxGetters<Store.State> {}

    public enum Mutation {
      case setInspectedWidget(Widget)
    }

    public enum Action {

    }
  }
}