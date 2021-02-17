import ReactiveProperties

extension Widget {
  public func stylePropertyValue<T: StyleValue>(_ key: StyleKey, as: T.Type) -> T? {
    stylePropertyValue(key) as? T
  }

  public func stylePropertyValue(_ key: StyleKey) -> StyleValue? {
    stylePropertiesResolver[key]
  }

  public func stylePropertyValue<T: StyleValue>(reactive key: StyleKey) -> ObservableProperty<T?> {
    stylePropertiesResolver[reactive: key]
  }

  public func stylePropertyValue(reactive key: StyleKey) -> ObservableProperty<StyleValue?> {
    stylePropertiesResolver[reactive: key]
  }
}