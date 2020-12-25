import Events

public class StaticProperty<Value>: ReactiveProperty {
  public typealias Value = Value

  public let onChanged = EventHandlerManager<(old: Value, new: Value)>()
  public let onAnyChanged = EventHandlerManager<(old: Any, new: Any)>()

  public let value: Value
  public let hasValue: Bool = true
  public let onHasValueChanged = EventHandlerManager<Void>()

  public var sourceBindings: [PropertyBindingProtocol] = []

  public init(_ value: Value) {
    self.value = value
  }
}