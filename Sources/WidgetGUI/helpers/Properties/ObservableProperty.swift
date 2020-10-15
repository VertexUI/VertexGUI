import VisualAppBase

@propertyWrapper
public class ObservableProperty<V>: ObservableProtocol {
  public typealias Value = V

  //private var _value: Value
  public var value: Value {
    fatalError("value not implemented")
    //_value
  }

  public var wrappedValue: Value {
    value
  }

  public var projectedValue: ObservableProperty<Value> {
    return self
  }

  private var _any: AnyObservableProperty?
  public var any: AnyObservableProperty  {
    if _any == nil {
      _any = AnyObservableProperty(self)
    }
    return _any!
  }

  public internal(set) var onChanged = EventHandlerManager<Value>()

  /*private let otherObservable: AnyObject
  private var removeOtherObservableChangedHandler: (() -> ())? = nil*/

  /*public init<O: ObservableProtocol>(from otherObservable: O) where O.Value == Value {
    self.otherObservable = otherObservable
    self._value = otherObservable.value
    self.removeOtherObservableChangedHandler = otherObservable.onChanged { [unowned self] in
      self._value = otherObservable.value
      onChanged.invokeHandlers($0)
    }
  }

  deinit {
    if let remove = removeOtherObservableChangedHandler {
      remove()
    }
    onChanged.removeAllHandlers()
  }*/

  public init() {}
}

public class AnyObservableProperty {
  public let onChanged = EventHandlerManager<Void>()
  private unowned let otherObservable: AnyObject
  private var removeOtherObservableChangedHandler: (() -> ())? = nil
 
  public init<V>(_ otherObservable: ObservableProperty<V>) {
    self.otherObservable = otherObservable
    self.removeOtherObservableChangedHandler = otherObservable.onChanged { [unowned self] _ in
      onChanged.invokeHandlers(Void())
    }
  }

  deinit {
    if let remove = removeOtherObservableChangedHandler {
      remove()
    }
    onChanged.removeAllHandlers()
  }
}

