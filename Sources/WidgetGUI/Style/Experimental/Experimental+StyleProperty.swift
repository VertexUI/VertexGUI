import ReactiveProperties

public protocol ExperimentalAnyStylePropertyProtocol: class {
  var anyValue: Any? { get set }
}

public protocol ExperimentalStylePropertyProtocol: ExperimentalAnyStylePropertyProtocol {
  associatedtype Value

  var value: Value { get set }
}

extension ExperimentalStylePropertyProtocol {
  public var anyValue: Any? {
    get {
      value
    }
    set {
      value = newValue as! Value
    }
  }
}

extension Experimental {
  @propertyWrapper
  public class DefaultStyleProperty<V>: ExperimentalStylePropertyProtocol {
    public typealias ValueKeyPath = ReferenceWritableKeyPath<Widget, Value>
    public typealias SelfKeyPath = ReferenceWritableKeyPath<Widget, DefaultStyleProperty<Value>>
    public typealias Value = V

    @MutableProperty
    public var value: Value

    public let observable = ObservableProperty<Value>()

    public static subscript(
      _enclosingInstance instance: Widget,
      wrapped wrappedKeyPath: ValueKeyPath,
      storage storageKeyPath: SelfKeyPath
    ) -> Value {
      get {
        instance[keyPath: storageKeyPath].value
      }
      set {
        instance[keyPath: storageKeyPath].value = newValue
      }
    }

    public var wrappedValue: Value {
      get { fatalError() }
      set { fatalError() }
    }
    
    public var projectedValue: DefaultStyleProperty<Value> {
      self
    }

    public init(wrappedValue: Value) {
      self.value = wrappedValue
      // DANGLING HANDLER
      _ = observable.bind($value)
    }
  }

  @propertyWrapper
  public class SpecialStyleProperty<Container: Widget, Value>: ExperimentalStylePropertyProtocol {
    public typealias ValueKeyPath = ReferenceWritableKeyPath<Container, Value>
    public typealias SelfKeyPath = ReferenceWritableKeyPath<Container, SpecialStyleProperty<Container, Value>>

    @MutableProperty
    public var value: Value

    public var projectedValue: SpecialStyleProperty<Container, Value> {
      self
    }

    public let observable = ObservableProperty<Value>()

    public static subscript(
      _enclosingInstance instance: Container,
      wrapped wrappedKeyPath: ValueKeyPath,
      storage storageKeyPath: SelfKeyPath
    ) -> Value {
      get {
        instance[keyPath: storageKeyPath].value
      }
      set {
        instance[keyPath: storageKeyPath].value = newValue
      }
    }

    public var wrappedValue: Value {
      get { fatalError() }
      set { fatalError() }
    }

    public init(wrappedValue: Value) {
      self.value = wrappedValue
      // DANGLING HANDLER
      _ = observable.bind($value)
    }
  }
}