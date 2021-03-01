import ReactiveProperties
import CombineX

protocol ExperimentalInternalStylePropertyProtocol: class {
  //var anyStyleValue: Experimental.AnyStylePropertyValue? { get set }
  var definitionValue: Experimental.StylePropertyValueDefinition.Value? { get set }
}

protocol ExperimentalStylePropertyProtocol: ExperimentalInternalStylePropertyProtocol {
  associatedtype Value

  var styleValue: Experimental.StylePropertyValue<Value>? { get set }
  var reactiveSourceSubscription: AnyCancellable? { get set }
}

extension ExperimentalStylePropertyProtocol {
  func updateStyleValue() {
    reactiveSourceSubscription?.cancel()

    if let definitionValue = definitionValue {
      switch definitionValue {
      case let .constant(value):
        styleValue = Experimental.StylePropertyValue(value)!
      case let .reactive(publisher):
        reactiveSourceSubscription = publisher.sink { [unowned self] in
          styleValue = Experimental.StylePropertyValue($0)!
        }
      }
    } else {
      styleValue = nil
    }
  }

  /*public var anyStyleValue: Experimental.AnyStylePropertyValue? {
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
  }*/
}

extension Experimental {
  @propertyWrapper
  public class DefaultStyleProperty<V>: ExperimentalStylePropertyProtocol {
    public typealias ValueKeyPath = ReferenceWritableKeyPath<Widget, Value>
    public typealias SelfKeyPath = ReferenceWritableKeyPath<Widget, DefaultStyleProperty<Value>>
    public typealias Value = V

    var concreteDefaultValue: Value
    var defaultValue: Experimental.StylePropertyValue<Value>

    var definitionValue: Experimental.StylePropertyValueDefinition.Value? = nil {
      didSet {
        updateStyleValue()
      }
    }

    var reactiveSourceSubscription: AnyCancellable?

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

    var definitionValue: Experimental.StylePropertyValueDefinition.Value? = nil {
      didSet {
        updateStyleValue()
      }
    }

    var reactiveSourceSubscription: AnyCancellable?

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
        if let styleValue = styleValue {
          switch styleValue {
          case .inherit:
            return concreteDefaultValue
          case let .some(value):
            return value
          }
        } else {
          return concreteDefaultValue
        }
      }, dependencies: [$styleValue])
      // DANGLING HANDLER
      _ = observable.bind($resolvedValue)
    }
  }
}