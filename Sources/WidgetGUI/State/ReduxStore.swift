open class ReduxStore<S, G: ReduxGetters<S>, A> {
  public typealias State = S
  public typealias Getters = G
  public typealias Action = A

  @ObservableProperty public var state: State
  private var mutableObservableState: MutableProperty<State>

  public let getters: Getters

  public init(initialState: S) {
    self.mutableObservableState = MutableProperty(wrappedValue: initialState)
    self.getters = Getters(mutableObservableState)
    self._state = mutableObservableState
  }

  private func _reduce(_ action: A, next: (@escaping () -> ()) -> ()) -> State {
    reduce(action, next: next)
  }

  open func reduce(_ action: A, next: (@escaping () -> ()) -> ()) -> State {
    fatalError("reduce(action:) not implemented")
  }

  public func dispatch(_ action: A) {
    var nextBlocks = [() -> ()]()
    self.mutableObservableState.value = _reduce(action) {
      nextBlocks.append($0)
    }
    for block in nextBlocks {
      block()
    }
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