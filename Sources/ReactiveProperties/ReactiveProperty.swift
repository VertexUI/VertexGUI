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

internal protocol InternalReactivePropertyProtocol: ReactiveProperty {

}

extension InternalReactivePropertyProtocol {
  internal func handleDependencyRecording() {
    if DependencyRecorder.current.recording {
      if !hasValue {
        fatalError("in order for properties to be recorded as dependencies automatically, an initial value has to be set")
      } else {
        DependencyRecorder.current.recordAccess(self)
      }
    }
  }
}