public protocol ExperimentalMutableReactiveProperty: ExperimentalReactiveProperty {
  var value: Value { get set }
}

protocol ExperimentalInternalMutableReactiveProperty: ExperimentalMutableReactiveProperty, ExperimentalInternalReactiveProperty {}