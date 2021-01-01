import Events

public protocol PublicComputedPropertyProtocol {
  func notifyDependenciesChanged()
}

internal protocol ComputedPropertyProtocol: PublicComputedPropertyProtocol, InternalReactivePropertyProtocol, EventfulObject {
  var dependencies: [AnyReactiveProperty] { get }
  var dependencyHandlerRemovers: [() -> ()] { get set }
  var _value: Value? { get set }
  var hasValue: Bool { get set }
  var compute: () -> Value { get }

  var destroyed: Bool { get set }
 
  func setupDependencyHandlers()
  func removeDependencyHandlers()
  func checkUpdateHasValue()
  func updateValue()
  func destroy()
}

extension ComputedPropertyProtocol {
  public func notifyDependenciesChanged() {
    checkUpdateHasValue()
    if dependencies.count == 0 {
      hasValue = true
    }
    updateValue()
  }

  func setupDependencyHandlers() {
    for dependency in dependencies {
      dependencyHandlerRemovers.append(dependency.onAnyChanged { [unowned self] _ in
        updateValue()
      })
      dependencyHandlerRemovers.append(dependency.onHasValueChanged { [unowned self] _ in
        checkUpdateHasValue()
      })
    }
  }

  func removeDependencyHandlers() {
    for remove in dependencyHandlerRemovers {
      remove()
    }
    dependencyHandlerRemovers = []
  }

  func updateValue() {
    if hasValue {
      _value = compute()
    }
  }

  func checkUpdateHasValue() {
    hasValue = dependencies.allSatisfy { $0.hasValue }
  }

  func destroy() {
    if destroyed {
      return
    }
    removeDependencyHandlers()
    registeredBindings = []
    destroyed = true
    onDestroyed.invokeHandlers(())
    removeAllEventHandlers()
  }
}