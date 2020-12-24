import Events

public class StaticProperty<Value>: ReactiveProperty {
  public typealias Value = Value

  public let onChanged = EventHandlerManager<(old: Value, new: Value)>()

  public let value: Value

  public init(_ value: Value) {
    self.value = value
  }
}