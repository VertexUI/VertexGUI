import Events

@propertyWrapper
public class ObservableProperty<Value>: ReactiveProperty {
  public typealias Value = Value

  public let onChanged = EventHandlerManager<(old: Value, new: Value)>()

  public var value: Value {
    fatalError("value not implemented")
  } 

  public var wrappedValue: Value {
    value
  }

  public init() {}
}