import Events

@propertyWrapper
public class ObservableProperty<Value>: ReactiveProperty {
  public typealias Value = Value

  public var value: Value {
    fatalError("value not implemented")
  } 
  public let onChanged = EventHandlerManager<(old: Value, new: Value)>()
  public let onAnyChanged = EventHandlerManager<(old: Any, new: Any)>()

  public var hasValue: Bool = true {
    didSet {
      onHasValueChanged.invokeHandlers(())
    }
  }
  public let onHasValueChanged = EventHandlerManager<Void>()

  public var wrappedValue: Value {
    value
  }
  
  public var sourceBindings: [PropertyBindingProtocol] = []

  public init() {}
}