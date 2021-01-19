import Events

@propertyWrapper
// TODO: need to test ObservableProperty
public class ObservableProperty<Value>: ReactiveProperty, InternalValueSettableReactivePropertyProtocol {
  public typealias Value = Value

  private var _value: Value? {
    didSet {
      hasValue = true
    }
  }
  public internal(set) var value: Value {
    get {
      _value!
    }

    set {
      _value = newValue
    }
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
  
  public var registeredBindings = [PropertyBindingProtocol]()

  private var destroyed: Bool = false
  public let onDestroyed = EventHandlerManager<Void>()

  public init() {}

  @discardableResult
  public func bind<Other: ReactiveProperty>(_ other: Other) -> UniDirectionalPropertyBinding where Other.Value == Value {
    UniDirectionalPropertyBinding(source: other, sink: self)
  }
}