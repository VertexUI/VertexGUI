import ReactiveProperties

open class ReduxStore<S, G: ReduxGetters<S>, M, A> {
  public typealias State = S
  public typealias Getters = G
  public typealias Mutation = M
  public typealias Action = A

  @MutableProperty
  public private(set) var state: State
  private var _mutableState: State

  //public let getters: Getters

  private var dispatchingAction = false

  public init(initialState: S) {
    self._mutableState = initialState
    self.state = initialState
    //self.getters = Getters(self._state.observable)
  }

  open func performMutation(state: inout State, mutation: Mutation) {
    fatalError("performMutation() not implemented")
  }

  open func performAction(action: A) {
    fatalError("performAction() not implemented")
  }

  public func commit(_ mutation: Mutation) {
    var newState = _mutableState
    performMutation(state: &newState, mutation: mutation)
    _mutableState = newState
    if !dispatchingAction {
      state = _mutableState
    }
  }

  public func dispatch(_ action: A) {
    let isRootDispatch = !dispatchingAction
    dispatchingAction = true
    performAction(action: action)
    if isRootDispatch {
      dispatchingAction = false
      state = _mutableState
    }
  }
}

open class ReduxGetters<S> {
  public typealias State = S

  @ObservableProperty
  public var state: State

  required public init<R: ReactiveProperty>(state stateProperty: R) where R.Value == S {
    $state.bind(stateProperty)

    /*let mirror = Mirror(reflecting: self)
    for child in mirror.children {
      if var getter = child.value as? ReduxGetterMarkerProtocol {
        getter.dependencies = [$state.any]
        getter.anyObservableState = $state
      }
    }*/
  }
}