import ExperimentalReactiveProperties
import Events

extension Experimental {
  public class StyleProperty: EventfulObject {
    public var key: StyleKey
    private var _value: Value
    public var value: StyleValue {
      switch _value {
      case let .static(value):
        return value
      case let .reactive(wrapper):
        return wrapper.value
      }
    }
    public var canChange: Bool {
      if case let .reactive(_) = _value {
        return true
      }
      return false
    }

    public let onChanged = EventHandlerManager<Void>()

    public init(key: StyleKey, value: StyleValue) {
      self.key = key
      self._value = .static(value)
    }

    public init<P: ReactiveProperty>(key: StyleKey, value valueProperty: P) where P.Value: StyleValue {
      self.key = key
      let computedWrapperProperty = ComputedProperty<StyleValue>(compute: {
        valueProperty.value
      }, dependencies: [valueProperty])
      self._value = .reactive(computedWrapperProperty)
      _ = computedWrapperProperty.onChanged { _ in
        self.onChanged.invokeHandlers()
      }
    }

    deinit {
      removeAllEventHandlers()
    }

    private enum Value {
      case `static`(StyleValue)
      case reactive(ComputedProperty<StyleValue>)
    }
  }
}