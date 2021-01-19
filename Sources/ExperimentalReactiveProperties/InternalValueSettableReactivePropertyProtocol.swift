internal protocol InternalValueSettableReactivePropertyProtocol: ReactiveProperty, InternalReactivePropertyProtocol {
  var value: Value { get set }
}