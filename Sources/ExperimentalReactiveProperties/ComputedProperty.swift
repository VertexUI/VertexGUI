import Events

public class ComputedProperty<Value>: ReactiveProperty {
  public typealias Value = Value
  public typealias ComputeFunction = () -> Value

  private let compute: ComputeFunction
  private let dependencies: [AnyReactiveProperty]
  
  public let onChanged = EventHandlerManager<(old: Value, new: Value)>()
  public let onAnyChanged = EventHandlerManager<(old: Any, new: Any)>()

  public var value: Value {
    fatalError("not implemented")
  }
  public var hasValue: Bool = true

  public var sourceBindings: [PropertyBindingProtocol] = []
  
  /**
  Dependencies of compute function will be automatically determind. This might not be 
  suitable for all types of compute functions. Use init(compute:, dependencies:) if you
  want to specify the dependencies manually.
  */
  public init(compute: @escaping ComputeFunction) {
    self.compute = compute
    self.dependencies = []
  }
}