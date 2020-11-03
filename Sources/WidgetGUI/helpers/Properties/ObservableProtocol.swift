import VisualAppBase

// TODO: maybe have Observable as base protocol with onChanged and then implement things like ObservableValue, ObservableArray on top of that
// TODO: might rename to Observable and remove Observable class
public protocol ObservableProtocol: class {
  associatedtype Value
  var value: Value { get }
  var onChanged: EventHandlerManager<Value> { get }
}
