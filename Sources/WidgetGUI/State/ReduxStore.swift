open class ReduxStore<S, A> {
  public typealias State = S

  @ObservableProperty public var state: State
  @MutableProperty private var mutableState: State

  public init(initialState: S) {
    self.mutableState = initialState
    self._state = $mutableState
  }

  private func _reduce(_ action: A) -> State {
    reduce(action)
  }

  open func reduce(_ action: A) -> State {
    fatalError("reduce(action:) not implemented")
  }

  public func dispatch(_ action: A) {
    self.mutableState = _reduce(action)
  }
}