import ExperimentalReactiveProperties
import Events

extension Experimental {
  public class StyleProperty: EventfulObject {
    public var key: StyleKey
    private var _value: Value
    public var value: Value {
      _value
    }/* {
      switch _value {
      case let .static(value):
        return value
      case let .reactive(wrapper):
        return wrapper.value
      }
    }*/
    public var canChange: Bool {
      if case let .reactive(_) = _value {
        return true
      }
      return false
    }

    /** place something in here to avoid it's deallocation for the lifetime of the StyleProperty */
    private var ownedObjects: [AnyObject] = []

    public let onChanged = EventHandlerManager<Void>()

    public init(key: StyleKey, value: StyleValue) {
      self.key = key
      self._value = .static(value)
    }

    public init<P: ReactiveProperty>(key: StyleKey, value valueProperty: P) where P.Value == StyleValue? {
      self.key = key
      
      /*let computedWrapperProperty = ComputedProperty<StyleValue?>(compute: {
        valueProperty.value
      }, dependencies: [valueProperty])*/

      let derivedObservableProperty = ObservableProperty<StyleValue?>()
      derivedObservableProperty.bind(valueProperty)

      self._value = .reactive(derivedObservableProperty)

      _ = derivedObservableProperty.onChanged { _ in
        self.onChanged.invokeHandlers()
      }
      //self.ownedObjects.append(computedWrapperProperty)
    }

    public init<P: ReactiveProperty>(key: StyleKey, value valueProperty: P) where P.Value: StyleValue {
      self.key = key

      let computedWrapperProperty = ComputedProperty<StyleValue?>(compute: {
        Optional(valueProperty.value)
      }, dependencies: [valueProperty])

      let derivedObservableProperty = ObservableProperty<StyleValue?>()
      derivedObservableProperty.bind(computedWrapperProperty)

      self._value = .reactive(derivedObservableProperty)

      _ = derivedObservableProperty.onChanged { _ in
        self.onChanged.invokeHandlers()
      }

      self.ownedObjects.append(computedWrapperProperty)
    }

    deinit {
      removeAllEventHandlers()
    }

    public enum Value {
      case `static`(StyleValue?)
      case reactive(ObservableProperty<StyleValue?>)
    }
  }
}