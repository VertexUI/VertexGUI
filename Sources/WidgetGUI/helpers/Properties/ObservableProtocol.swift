import VisualAppBase

public protocol AnyObservableProtocol: class {
  var any: AnyObservableProperty { get }
}

// TODO: maybe have Observable as base protocol with onChanged and then implement things like ObservableValue, ObservableArray on top of that
// TODO: might rename to Observable and remove Observable class
public protocol ObservableProtocol: AnyObservableProtocol {
  associatedtype Value
  var value: Value { get }
  var onChanged: EventHandlerManager<Value> { get }
}

internal protocol AnyEquatableObservableProtocol {
  func valuesEqual(_ value1: Any?, _ value2: Any?) -> Bool
}