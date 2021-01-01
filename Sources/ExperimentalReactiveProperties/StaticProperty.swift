import Events

public class StaticProperty<Value>: InternalReactivePropertyProtocol {
  public typealias Value = Value

  public let onChanged = EventHandlerManager<(old: Value, new: Value)>()
  public let onAnyChanged = EventHandlerManager<(old: Any, new: Any)>()

  private let _value: Value
  public var value: Value {
    get {
      handleDependencyRecording()
      return _value
    }
  }
  public let hasValue: Bool = true
  public let onHasValueChanged = EventHandlerManager<Void>()
  
  public var registeredBindings = [PropertyBindingProtocol]()

  private var destroyed: Bool = false
  public let onDestroyed = EventHandlerManager<Void>()

  public init(_ value: Value) {
    self._value = value
  }
}