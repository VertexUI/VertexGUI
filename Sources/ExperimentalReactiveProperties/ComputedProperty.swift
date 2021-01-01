import Foundation
import Events

public class ComputedProperty<Value>: ComputedPropertyProtocol, EventfulObject {
  public typealias Value = Value
  public typealias ComputeFunction = () -> Value
  
  internal var _value: Value? {
    didSet {
      if hasValue, oldValue != nil {
        invokeOnChangedHandlers(oldValue: oldValue!, newValue: _value!)
      } else {
        hasValue = true
      }
    }
  }
  public var value: Value {
    handleDependencyRecording()

    if hasValue {
      if _value == nil {
        _value = compute()
      }

      return _value!
    } else {
      fatalError("no value present, because some dependency does not have a value")
    }
  }
  internal let compute: ComputeFunction
  internal private(set) var dependencies: [AnyReactiveProperty]
  internal var dependencyHandlerRemovers = [() -> ()]()
  public let onChanged = EventHandlerManager<(old: Value, new: Value)>()
  public let onAnyChanged = EventHandlerManager<(old: Any, new: Any)>()

  public internal(set) var hasValue: Bool = false {
    didSet {
      if oldValue != hasValue {
        onHasValueChanged.invokeHandlers(())
      }
    }
  }
  public let onHasValueChanged = EventHandlerManager<Void>()

  public var registeredBindings = [PropertyBindingProtocol]()

  public internal(set) var destroyed: Bool = false
  public let onDestroyed = EventHandlerManager<Void>()

  /**
  Dependencies of compute function will be automatically determind. This might not be 
  suitable for all types of compute functions. Use init(compute:, dependencies:) if you
  want to specify the dependencies manually.
  */
  public init(compute: @escaping ComputeFunction) {
    self.compute = compute
    self.dependencies = []
    recordDependencies()
    setupDependencyHandlers()
    checkUpdateHasValue()
    if hasValue {
      _value = compute()
    }
  }

  /**
  Initialize with manual dependency definition. No further lookup or is performed
  on dependencies of the compute function.
  */
  public init(compute: @escaping ComputeFunction, dependencies: [AnyReactiveProperty]) {
    self.compute = compute
    self.dependencies = dependencies
    setupDependencyHandlers()
    checkUpdateHasValue()
    if hasValue {
      _value = compute()
    }
  }

  internal func recordDependencies() {
    DependencyRecorder.current.recording = true
    _ = self.compute()
    DependencyRecorder.current.recording = false
    self.dependencies = DependencyRecorder.current.recordedProperties
  }

  deinit {
    destroy()
  }
}