import ReactiveProperties

open class ReduxStore<S, G: ReduxGetters<S>, M, A> {
  public typealias State = S
  public typealias Getters = G
  public typealias Mutation = M
  public typealias Action = A

  @MutableProperty public private(set) var state: State
  private var _mutableState: State

  public let getters: Getters

  private var dispatchingAction = false

  public init(initialState: S) {
    self._mutableState = initialState
    self.state = initialState
    self.getters = Getters(self._state.observable)
  }

  open func performMutation(_ state: inout State, _ mutation: Mutation) {
    fatalError("performMutation() not implemented")
  }

  open func performAction(_ action: A) {
    fatalError("performAction() not implemented")
  }

  public func commit(_ mutation: Mutation) {
    var newState = _mutableState
    performMutation(&newState, mutation)
    _mutableState = newState
    if !dispatchingAction {
      state = _mutableState
    }
  }

  public func dispatch(_ action: A) {
    let isRootDispatch = !dispatchingAction
    dispatchingAction = true
    performAction(action)
    if isRootDispatch {
      dispatchingAction = false
      state = _mutableState
    }
  }
}

open class ReduxGetters<S> {
  public typealias State = S

  @ObservableProperty public var state: State

  required public init(_ observableState: ObservablePropertyBinding<State>) {
    self._state = observableState

    let mirror = Mirror(reflecting: self)
    for child in mirror.children {
      if var getter = child.value as? ReduxGetterMarkerProtocol {
        getter.dependencies = [$state.any]
        getter.anyObservableState = $state
      }
    }
  }
}