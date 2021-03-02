import ReactiveProperties
import CombineX

protocol ExperimentalAnyStylePropertyProtocol: class {
  //var anyStyleValue: Experimental.AnyStylePropertyValue? { get set }
  var definitionValue: Experimental.StylePropertyValueDefinition.Value? { get set }
  var container: Widget? { get set }
  var name: String? { get set }
}

protocol ExperimentalStylePropertyProtocol: ExperimentalAnyStylePropertyProtocol {
  associatedtype Container: Widget
  associatedtype Value

  var concreteDefaultValue: Value { get }
  var defaultValue: Experimental.StylePropertyValue<Value> { get }
  var styleValue: Experimental.StylePropertyValue<Value>? { get set }
  //var wrappedKeyPath: ValueKeyPath? { get }
  //var storageKeyPath: SelfKeyPath? { get }
  var resolvedValue: Value { get set }

  var definitionValueSourceSubscription: AnyCancellable? { get set }
  var parentValueSubscription: AnyCancellable? { get set }
}

extension ExperimentalStylePropertyProtocol {
  /*public typealias ValueKeyPath = ReferenceWritableKeyPath<Container, Value>
  public typealias SelfKeyPath = ReferenceWritableKeyPath<Container, Self>*/

  func updateStyleValue() {
    definitionValueSourceSubscription?.cancel()

    if let definitionValue = definitionValue {
      switch definitionValue {
      case let .constant(value):
        styleValue = Experimental.StylePropertyValue(value)!
      case let .reactive(publisher):
        definitionValueSourceSubscription = publisher.sink { [unowned self] in
          styleValue = Experimental.StylePropertyValue($0)!
        }
      }
    } else {
      styleValue = nil
    }
  }

  func updateResolvedValue() {
    parentValueSubscription?.cancel()

    outerSwitch: switch styleValue ?? defaultValue {
    case .inherit:
      guard let container = container, let name = name else {
        resolvedValue = concreteDefaultValue
        //print("warning: tried to resolve .inherit style property before setup by widget")
        return
      }

      if let parent = container.parent as? Container {
        let mirror = Mirror(reflecting: parent)
        for child in mirror.allChildren {
          if child.label == name, let property = child.value as? Experimental.StyleProperty<Value> {
            resolvedValue = property.resolvedValue
            parentValueSubscription = property.sink { [unowned self] in
              resolvedValue = $0
            }
            break outerSwitch
          }
        }
      }

      resolvedValue = concreteDefaultValue

    case let .some(value):
      resolvedValue = value
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
  public class StyleProperty<V>: ExperimentalStylePropertyProtocol, ExperimentalInternalReactiveProperty {
    public typealias Container = Widget
    public typealias Value = V

    weak var container: Container? {
      didSet {
        if oldValue !== container {
          updateResolvedValue()
        }
      }
    }
    var name: String?

    var concreteDefaultValue: Value
    var defaultValue: Experimental.StylePropertyValue<Value>

    var definitionValue: Experimental.StylePropertyValueDefinition.Value? = nil {
      didSet {
        updateStyleValue()
      }
    }

    var styleValue: Experimental.StylePropertyValue<Value>? = nil {
      didSet {
        updateResolvedValue()
      }
    }

    var resolvedValue: Value {
      didSet {
        notifyChange()
      }
    }

    var definitionValueSourceSubscription: AnyCancellable?
    var parentValueSubscription: AnyCancellable?

    public var value: Value {
      resolvedValue
    }

    var subscriptions: StyleProperty<V>.Subscriptions = []

    public init(wrappedValue: Value, default defaultValue: Experimental.StylePropertyValue<Value>? = nil) {
      self.concreteDefaultValue = wrappedValue
      self.defaultValue = defaultValue ?? .some(wrappedValue)
      self.styleValue = self.defaultValue
      self.resolvedValue = self.concreteDefaultValue
      self.updateResolvedValue()
    }
  }

  @propertyWrapper
  public final class DefaultStyleProperty<V>: StyleProperty<V> {
    /*public static subscript(
      _enclosingInstance instance: Widget,
      wrapped wrappedKeyPath: ReferenceWritableKeyPath<Widget, Value>,
      storage storageKeyPath: ReferenceWritableKeyPath<Widget, DefaultStyleProperty<Value>>
    ) -> Value {
      get {
        instance[keyPath: storageKeyPath].instance = instance
        instance[keyPath: storageKeyPath].storageKeyPath = storageKeyPath
        instance[keyPath: storageKeyPath].wrappedkeyPath = wrappedKeyPath
        return instance[keyPath: storageKeyPath].resolvedValue

        let resolvedValue: Value
        switch instance[keyPath: storageKeyPath].styleValue ?? instance[keyPath: storageKeyPath].defaultValue {
        case .inherit:
          if let parent = instance.parent as? Widget {
            resolvedValue = parent[keyPath: wrappedKeyPath]
            break
          }
          resolvedValue = instance[keyPath: storageKeyPath].concreteDefaultValue
        case let .some(value):
          resolvedValue = value
        }

        instance[keyPath: storageKeyPath].resolvedValue = resolvedValue

        return resolvedValue
      }
      set {
        instance[keyPath: storageKeyPath].concreteDefaultValue = newValue
      }
    }*/

    public var wrappedValue: Value {
      get { resolvedValue }
    }
    
    public var projectedValue: DefaultStyleProperty<Value> {
      self
    }
  }

  @propertyWrapper
  public final class SpecialStyleProperty<Container: Widget, V>: StyleProperty<V> {
    /*public typealias Container = Container
    public typealias Value = V

    weak var container: Widget? {
      didSet {
        if oldValue !== container {
          updateResolvedValue()
        }
      }
    }
    var name: String?

    var concreteDefaultValue: Value
    var defaultValue: Experimental.StylePropertyValue<Value>

    var definitionValue: Experimental.StylePropertyValueDefinition.Value? = nil {
      didSet {
        updateStyleValue()
      }
    }

    var definitionValueSourceSubscription: AnyCancellable?
    var parentValueSubscription: AnyCancellable?

    var styleValue: Experimental.StylePropertyValue<Value>? = nil {
      didSet {
        updateResolvedValue()
      }
    }

    @MutableProperty
    var resolvedValue: Value

    public let observable = ObservableProperty<Value>()

 

    /*public static subscript(
      _enclosingInstance instance: Container,
      wrapped wrappedKeyPath: ReferenceWritableKeyPath<Container, Value>,
      storage storageKeyPath: ReferenceWritableKeyPath<Container, SpecialStyleProperty<Container, Value>>
    ) -> Value {
      get {
        return instance[keyPath: storageKeyPath].resolvedValue
      }
      set {
        instance[keyPath: storageKeyPath].concreteDefaultValue = newValue
      }
    }*/*/

    public var wrappedValue: Value {
      get { resolvedValue }
    }
    
    public var projectedValue: SpecialStyleProperty<Container, Value> {
      self
    }

    /*public init(wrappedValue: Value, default defaultValue: Experimental.StylePropertyValue<Value>? = nil) {
      self.concreteDefaultValue = wrappedValue
      self.defaultValue = defaultValue ?? .some(wrappedValue)
      self.styleValue = self.defaultValue
      updateResolvedValue()
      // DANGLING HANDLER
      _ = observable.bind($resolvedValue)
    }*/
  }
}