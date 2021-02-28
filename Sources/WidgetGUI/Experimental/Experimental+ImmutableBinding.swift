extension Experimental {
  @propertyWrapper
  public class ImmutableBinding<V>: ExperimentalInternalReactiveProperty/*, Binding<V>*/ {
    public typealias Value = V

    private var dependency: AnyReactiveProperty<Value>
    private let _get: (AnyReactiveProperty<V>) -> Value

    public var value: Value {
      wrappedValue
    }
    public var wrappedValue: Value {
      /*guard let dependency = dependency else {
        fatalError("@ImmutableBinding read after it's dependency was deallocated.")
      }*/
      return dependency.value
    }

    var subscribers: Subscribers = []

    public init<P: ExperimentalReactiveProperty>(_ dependency: P, get _get: @escaping (AnyReactiveProperty<Value>) -> Value) where P.Value == Value {
      self._get = _get
      self.dependency = AnyReactiveProperty(dependency)
    }
  }
}