import ExperimentalReactiveProperties

@propertyWrapper
public class FromStyle<Value: StyleValue>: FromStyleProtocol {
  unowned private var widget: Widget?

  private var key: StyleKey

  @ExperimentalReactiveProperties.ObservableProperty
  private var value: Value?

  private let defaultValue: Value

  public var wrappedValue: Value {
    if $value.hasValue {
      return value ?? defaultValue
    } else {
      return defaultValue
    }
  }

  private var _projectedValue: ExperimentalReactiveProperties.ComputedProperty<Value>
  public var projectedValue: ExperimentalReactiveProperties.ComputedProperty<Value> {
    _projectedValue
  }

  public init(wrappedValue defaultValue: Value, key: StyleKey) {
    self.key = key
    self.defaultValue = defaultValue

    self._projectedValue = ExperimentalReactiveProperties.ComputedProperty()
    self._projectedValue.reinit(compute: { [unowned self] in
      wrappedValue
    }, dependencies: [$value])
  }

  internal func registerWidget(_ widget: Widget) {
    self.widget = widget
    self.$value.bind(widget.stylePropertyValue(reactive: key))
  }
}

internal protocol FromStyleProtocol {
  func registerWidget(_ widget: Widget)
}