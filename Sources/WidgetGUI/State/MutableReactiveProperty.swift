public protocol MutableReactiveProperty: ReactiveProperty {
  var value: Value { get set }
}

protocol InternalMutableReactiveProperty: MutableReactiveProperty, InternalReactiveProperty {}