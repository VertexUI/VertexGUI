extension Widget {
  @discardableResult
  public func with(@StylePropertiesBuilder styleProperties: (StyleKeys.Type) -> StyleProperties) -> Widget {
    directStyleProperties.append(styleProperties(StyleKeys.self))
    return self
  }

  @discardableResult
  public func with(_ styleProperties: StyleProperties) -> Widget {
    directStyleProperties.append(styleProperties)
    return self
  }
}