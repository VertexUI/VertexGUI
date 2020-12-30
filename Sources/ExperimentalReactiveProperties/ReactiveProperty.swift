import Events

public protocol ReactiveProperty: AnyReactiveProperty {
  associatedtype Value

  var value: Value { get }

  var onChanged: EventHandlerManager<(old: Value, new: Value)> { get }
}

extension ReactiveProperty {
  /**
  Invoke the onChanged as well as the onAnyChanged handlers.
  */
  public func invokeOnChangedHandlers(oldValue: Value, newValue: Value) {
    onChanged.invokeHandlers((old: oldValue, new: newValue))
    onAnyChanged.invokeHandlers((old: oldValue, new: newValue))
  }
}