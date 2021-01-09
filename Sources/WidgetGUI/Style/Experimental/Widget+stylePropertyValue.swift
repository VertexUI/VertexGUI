extension Widget {
  public func stylePropertyValue<T: StyleValue>(_ key: StyleKey, as: T.Type) -> T? {
    stylePropertyValue(key) as? T
  }

  public func stylePropertyValue(_ key: StyleKey) -> StyleValue? {
    for property in experimentalAppliedStyleProperties {
      if property.key.asString == key.asString {
        return property.value
      }
    }

    return nil
  }
}