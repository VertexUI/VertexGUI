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

  public init(wrappedValue defaultValue: Value, key: StyleKey) {
    self.key = key
    self.defaultValue = defaultValue
  }

  internal func registerWidget(_ widget: Widget) {
    self.widget = widget
    self.$value.bind(widget.stylePropertyValue(reactive: key))
  }
}

internal protocol FromStyleProtocol {
  func registerWidget(_ widget: Widget)
}