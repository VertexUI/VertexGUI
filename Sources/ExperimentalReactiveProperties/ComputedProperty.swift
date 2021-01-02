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
  internal var compute: ComputeFunction
  internal var dependencies: [AnyReactiveProperty]
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

  public init() {
    self.compute = { fatalError("tried to call compute() on a property that has not been fully initialized") }
    self.dependencies = []
  }

  /**
  If the dependencies are not specified, they will be automatically registered based on the
  accesses that happen in the compute function. That means the compute function needs to be
  able to execute without error right away. If this is not possible in a specific case, provide
  the dependencies manually.
  */
  public init(compute: @escaping ComputeFunction, dependencies: [AnyReactiveProperty]? = nil) {
    self.compute = compute
    if let dependencies = dependencies {
      self.dependencies = dependencies
    } else {
      self.dependencies = []
      recordDependencies()
    }
    setupDependencyHandlers()
    checkUpdateHasValue()
    if hasValue {
      _value = compute()
    }
  }

  public func reinit(compute: @escaping ComputeFunction, dependencies: [AnyReactiveProperty]? = nil) {
    self.removeDependencyHandlers()
    self.compute = compute
    if let dependencies = dependencies {
      self.dependencies = dependencies
    } else {
      self.dependencies = []
      recordDependencies()
    }
    setupDependencyHandlers()
    checkUpdateHasValue()
    if hasValue {
      _value = compute()
    }
  }

  deinit {
    destroy()
  }
}