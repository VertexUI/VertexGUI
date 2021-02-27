import ReactiveProperties

public protocol ExperimentalAnyStylePropertyProtocol: class {
  var anyStyleValue: Experimental.AnyStylePropertyValue? { get set }
}

protocol ExperimentalStylePropertyProtocol: ExperimentalAnyStylePropertyProtocol {
  associatedtype Value

  var styleValue: Experimental.StylePropertyValue<Value>? { get set }
}

extension ExperimentalStylePropertyProtocol {
  public var anyStyleValue: Experimental.AnyStylePropertyValue? {
    get {
      Experimental.AnyStylePropertyValue(styleValue)
    }
    set {
      if let newValue = newValue {
        switch newValue {
        case .inherit:
          styleValue = .inherit
        case let .some(value):
          styleValue = .some(value as! Value)
        }
      } else {
        styleValue = nil
      }
    }
  }
}

extension Experimental {
  @propertyWrapper
  public class DefaultStyleProperty<V>: ExperimentalStylePropertyProtocol {
    public typealias ValueKeyPath = ReferenceWritableKeyPath<Widget, Value>
    public typealias SelfKeyPath = ReferenceWritableKeyPath<Widget, DefaultStyleProperty<Value>>
    public typealias Value = V

    var concreteDefaultValue: Value
    var defaultValue: Experimental.StylePropertyValue<Value>

    public let observable = ObservableProperty<Value>()

    @MutableProperty
    var styleValue: Experimental.StylePropertyValue<Value>? = nil

    @ComputedProperty
    var resolvedValue: Value

    public static subscript(
      _enclosingInstance instance: Widget,
      wrapped wrappedKeyPath: ValueKeyPath,
      storage storageKeyPath: SelfKeyPath
    ) -> Value {
      get {
        switch instance[keyPath: storageKeyPath].styleValue ?? instance[keyPath: storageKeyPath].defaultValue {
        case .inherit:
          if let parent = instance.parent as? Widget {
            return parent[keyPath: wrappedKeyPath]
          }
          return instance[keyPath: storageKeyPath].concreteDefaultValue
        case let .some(value):
          return value
        }
      }
      set {
        instance[keyPath: storageKeyPath].concreteDefaultValue = newValue
      }
    }

    public var wrappedValue: Value {
      get { fatalError() }
      set { fatalError() }
    }
    
    public var projectedValue: DefaultStyleProperty<Value> {
      self
    }

    public init(wrappedValue: Value, default defaultValue: Experimental.StylePropertyValue<Value>? = nil) {
      self.concreteDefaultValue = wrappedValue
      self.defaultValue = defaultValue ?? .some(wrappedValue)
      self.styleValue = self.defaultValue
      self.$resolvedValue.reinit(compute: { [unowned self] in
        concreteDefaultValue
      }, dependencies: [$styleValue])
      // DANGLING HANDLER
      _ = observable.bind($resolvedValue)
    }
  }

  @propertyWrapper
  public class SpecialStyleProperty<Container: Widget, Value>: ExperimentalStylePropertyProtocol {
    public typealias ValueKeyPath = ReferenceWritableKeyPath<Container, Value>
    public typealias SelfKeyPath = ReferenceWritableKeyPath<Container, SpecialStyleProperty<Container, Value>>

    var concreteDefaultValue: Value
    var defaultValue: Experimental.StylePropertyValue<Value>

    public var projectedValue: SpecialStyleProperty<Container, Value> {
      self
    }

    public let observable = ObservableProperty<Value>()

    @MutableProperty
    var styleValue: Experimental.StylePropertyValue<Value>? = nil

    @ComputedProperty
    var resolvedValue: Value

    public static subscript(
      _enclosingInstance instance: Container,
      wrapped wrappedKeyPath: ValueKeyPath,
      storage storageKeyPath: SelfKeyPath
    ) -> Value {
      get {
        return instance[keyPath: storageKeyPath].resolvedValue
      }
      set {
        instance[keyPath: storageKeyPath].concreteDefaultValue = newValue
      }
    }

    public var wrappedValue: Value {
      get { fatalError() }
      set { fatalError() }
    }

    public init(wrappedValue: Value, default defaultValue: Experimental.StylePropertyValue<Value>? = nil) {
      self.concreteDefaultValue = wrappedValue
      self.defaultValue = defaultValue ?? .some(wrappedValue)
      self.styleValue = self.defaultValue
      self.$resolvedValue.reinit(compute: { [unowned self] in
        concreteDefaultValue
      }, dependencies: [$styleValue])
      // DANGLING HANDLER
      _ = observable.bind($resolvedValue)
    }
  }
}