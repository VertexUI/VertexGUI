import CXShim

extension Experimental {
  open class Store<S, M, A> {
    public typealias State = S
    public typealias Mutation = M
    public typealias Action = A

    @StatePropertyWrapper
    public var state: State
    var stateWrapper: StatePropertyWrapper<State> {
      _state
    }
    public typealias SetterProxy = StateSetterProxy<Store<S, M, A>, S, M, A>
    lazy var setterProxy = StateSetterProxy(store: self)

    public init(initialState: State) {
      self._state = StatePropertyWrapper(initialState: initialState)
    }

    open func perform(mutation: Mutation, state: SetterProxy) {
      fatalError("perform(mutation:) not implemented")
    }

    open func perform(action: Action) -> Future<Void, Error> {
      fatalError("perform(mutation:) not implemented")
    }

    public func commit(_ mutation: Mutation) {
      perform(mutation: mutation, state: setterProxy)
    }

    @discardableResult public func dispatch(_ action: Action) -> Future<Void, Error> {
      perform(action: action)
    }
  }

  @propertyWrapper
  public class StatePropertyWrapper<S> {
    var state: S
    public var wrappedValue: S {
      state
    }

    lazy public private(set) var projectedValue = ImmutableStateBindingProxy(stateWrapper: self)
    var propertyBindings: [AnyKeyPath: ExperimentalAnyErasedInternalReactiveProperty] = [:]

    public init(initialState: S) {
      self.state = initialState
    }
  }

  @dynamicMemberLookup
  public class ImmutableStateBindingProxy<StateWrapper: StatePropertyWrapper<State>, State> {
    unowned let stateWrapper: StateWrapper

    init(stateWrapper: StateWrapper) {
      self.stateWrapper = stateWrapper
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> Experimental.ReactivePropertyProjection<T> {
      if stateWrapper.propertyBindings[keyPath] == nil {
        let newBinding = ImmutableBinding(get: { [unowned self] in stateWrapper.state[keyPath: keyPath] })
        stateWrapper.propertyBindings[keyPath] = ExperimentalAnyErasedInternalReactiveProperty(wrapping: newBinding)
      }
      return (stateWrapper.propertyBindings[keyPath]!.wrapped as! ImmutableBinding<T>).projectedValue 
    }
  }

  @dynamicMemberLookup
  public class StateSetterProxy<S: Store<State, M, A>, State, M, A> {
    unowned let store: S

    init(store: S) {
      self.store = store
    }

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<State, T>) -> T {
      get {
        store.stateWrapper.state[keyPath: keyPath]
      }

      set {
        store.stateWrapper.state[keyPath: keyPath] = newValue
        if let binding = store.stateWrapper.propertyBindings[keyPath] {
          binding.notifyChange()
        }
      }
    }
  }
}