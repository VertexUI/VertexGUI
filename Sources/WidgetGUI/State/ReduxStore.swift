open class ReduxStore<S, G: ReduxGetters<S>, A> {
  public typealias State = S
  public typealias Getters = G

  @ObservableProperty public var state: State
  private var mutableObservableState: MutableProperty<State>

  public let getters: Getters

  public init(initialState: S) {
    self.mutableObservableState = MutableProperty(wrappedValue: initialState)
    self.getters = Getters(mutableObservableState)
    self._state = mutableObservableState
  }

  private func _reduce(_ action: A) -> State {
    reduce(action)
  }

  open func reduce(_ action: A) -> State {
    fatalError("reduce(action:) not implemented")
  }

  public func dispatch(_ action: A) {
    self.mutableObservableState.value = _reduce(action)
  }
}

open class ReduxGetters<S> {
  public typealias State = S

  @ObservableProperty public var state: State

  required public init(_ observableState: ObservableProperty<State>) {
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