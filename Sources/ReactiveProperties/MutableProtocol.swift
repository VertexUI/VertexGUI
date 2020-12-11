import Events

// TODO: does this protocol have any use? probably not
public protocol MutableProtocol: class {
  associatedtype Value
  var value: Value { get set }
  var onChanged: EventHandlerManager<ObservableChangedEventData<Value>> { get }
}